import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tracker/models/habit_model.dart';

class HabitProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<HabitModel> _habits = [];
  bool _isLoading = false;
  String? _error;
  HabitCategory? _selectedCategory;

  List<HabitModel> get habits => _selectedCategory != null
      ? _habits.where((habit) => habit.category == _selectedCategory).toList()
      : _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;
  HabitCategory? get selectedCategory => _selectedCategory;

  List<HabitModel> get todayHabits {
    final today = DateTime.now();
    return _habits.where((habit) {
      if (habit.frequency == HabitFrequency.daily) {
        return true; // Show all daily habits
      } else {
        // For weekly habits, check if it's the current week
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return today.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
               today.isBefore(endOfWeek.add(const Duration(days: 1)));
      }
    }).toList();
  }

  void setSelectedCategory(HabitCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadHabits() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .orderBy('createdAt', descending: true)
          .get();

      _habits = snapshot.docs
          .map((doc) => HabitModel.fromMap(doc.data(), doc.id))
          .toList();

      // Calculate streaks for all habits
      for (int i = 0; i < _habits.length; i++) {
        _habits[i] = _habits[i].copyWith(
          currentStreak: _calculateStreak(_habits[i]),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load habits: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createHabit({
    required String title,
    required HabitCategory category,
    required HabitFrequency frequency,
    DateTime? startDate,
    String? notes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final habit = HabitModel(
        id: '', // Will be set by Firestore
        title: title,
        category: category,
        frequency: frequency,
        startDate: startDate,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .add(habit.toMap());

      final newHabit = habit.copyWith(id: docRef.id);
      _habits.insert(0, newHabit);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create habit: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateHabit({
    required String habitId,
    String? title,
    HabitCategory? category,
    HabitFrequency? frequency,
    DateTime? startDate,
    String? notes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) throw 'Habit not found';

      final updatedHabit = _habits[habitIndex].copyWith(
        title: title ?? _habits[habitIndex].title,
        category: category ?? _habits[habitIndex].category,
        frequency: frequency ?? _habits[habitIndex].frequency,
        startDate: startDate ?? _habits[habitIndex].startDate,
        notes: notes ?? _habits[habitIndex].notes,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId)
          .update(updatedHabit.toMap());

      _habits[habitIndex] = updatedHabit;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update habit: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteHabit(String habitId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId)
          .delete();

      _habits.removeWhere((habit) => habit.id == habitId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete habit: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleHabitCompletion(String habitId, DateTime date) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) throw 'Habit not found';

      final habit = _habits[habitIndex];
      if (!habit.canCompleteForDate(date)) {
        throw 'Cannot complete habit for this date';
      }

      final dateOnly = DateTime(date.year, date.month, date.day);
      final isCompleted = habit.isCompletedForDate(date);
      
      List<DateTime> newCompletionHistory = List.from(habit.completionHistory);
      
      if (isCompleted) {
        // Remove completion
        newCompletionHistory.removeWhere((completionDate) {
          final completionDateOnly = DateTime(
            completionDate.year,
            completionDate.month,
            completionDate.day,
          );
          return completionDateOnly.isAtSameMomentAs(dateOnly);
        });
      } else {
        // Add completion
        newCompletionHistory.add(dateOnly);
      }

      final updatedHabit = habit.copyWith(
        completionHistory: newCompletionHistory,
        currentStreak: _calculateStreak(habit.copyWith(
          completionHistory: newCompletionHistory,
        )),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId)
          .update(updatedHabit.toMap());

      _habits[habitIndex] = updatedHabit;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to toggle habit completion: $e';
      notifyListeners();
      return false;
    }
  }

  int _calculateStreak(HabitModel habit) {
    if (habit.completionHistory.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    List<DateTime> sortedDates = List.from(habit.completionHistory)
      ..sort((a, b) => b.compareTo(a)); // Sort descending

    int streak = 0;
    DateTime currentDate = today;

    if (habit.frequency == HabitFrequency.daily) {
      // For daily habits, check consecutive days
      for (DateTime completionDate in sortedDates) {
        final completionDateOnly = DateTime(
          completionDate.year,
          completionDate.month,
          completionDate.day,
        );
        
        if (currentDate.isAtSameMomentAs(completionDateOnly)) {
          streak++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    } else {
      // For weekly habits, check consecutive weeks
      for (DateTime completionDate in sortedDates) {
        final completionDateOnly = DateTime(
          completionDate.year,
          completionDate.month,
          completionDate.day,
        );
        
        final startOfCurrentWeek = currentDate.subtract(
          Duration(days: currentDate.weekday - 1),
        );
        final endOfCurrentWeek = startOfCurrentWeek.add(
          const Duration(days: 6),
        );
        
        if (completionDateOnly.isAfter(startOfCurrentWeek.subtract(const Duration(days: 1))) &&
            completionDateOnly.isBefore(endOfCurrentWeek.add(const Duration(days: 1)))) {
          streak++;
          currentDate = startOfCurrentWeek.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    return streak;
  }

  List<HabitModel> getHabitsForDate(DateTime date) {
    return _habits.where((habit) {
      if (habit.frequency == HabitFrequency.daily) {
        return true;
      } else {
        final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
               date.isBefore(endOfWeek.add(const Duration(days: 1)));
      }
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
