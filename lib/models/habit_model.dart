enum HabitFrequency { daily, weekly }
enum HabitCategory { health, study, fitness, productivity, mentalHealth, others }

class HabitModel {
  final String id;
  final String title;
  final HabitCategory category;
  final HabitFrequency frequency;
  final DateTime? startDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int currentStreak;
  final List<DateTime> completionHistory;

  HabitModel({
    required this.id,
    required this.title,
    required this.category,
    required this.frequency,
    this.startDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.currentStreak = 0,
    this.completionHistory = const [],
  });

  factory HabitModel.fromMap(Map<String, dynamic> map, String id) {
    return HabitModel(
      id: id,
      title: map['title'] ?? '',
      category: HabitCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => HabitCategory.others,
      ),
      frequency: HabitFrequency.values.firstWhere(
        (e) => e.toString().split('.').last == map['frequency'],
        orElse: () => HabitFrequency.daily,
      ),
      startDate: map['startDate'] != null 
          ? DateTime.parse(map['startDate']) 
          : null,
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      currentStreak: map['currentStreak'] ?? 0,
      completionHistory: (map['completionHistory'] as List<dynamic>?)
          ?.map((date) => DateTime.parse(date))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category.toString().split('.').last,
      'frequency': frequency.toString().split('.').last,
      'startDate': startDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'currentStreak': currentStreak,
      'completionHistory': completionHistory
          .map((date) => date.toIso8601String())
          .toList(),
    };
  }

  HabitModel copyWith({
    String? id,
    String? title,
    HabitCategory? category,
    HabitFrequency? frequency,
    DateTime? startDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? currentStreak,
    List<DateTime>? completionHistory,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentStreak: currentStreak ?? this.currentStreak,
      completionHistory: completionHistory ?? this.completionHistory,
    );
  }

  bool isCompletedForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return completionHistory.any((completionDate) {
      final completionDateOnly = DateTime(
        completionDate.year, 
        completionDate.month, 
        completionDate.day,
      );
      return completionDateOnly.isAtSameMomentAs(dateOnly);
    });
  }

  bool canCompleteForDate(DateTime date) {
    final now = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final nowOnly = DateTime(now.year, now.month, now.day);
    
    // Can't complete for future dates
    if (dateOnly.isAfter(nowOnly)) return false;
    
    // For weekly habits, check if it's the same week
    if (frequency == HabitFrequency.weekly) {
      final startOfWeek = nowOnly.subtract(Duration(days: nowOnly.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return dateOnly.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
             dateOnly.isBefore(endOfWeek.add(const Duration(days: 1)));
    }
    
    return true;
  }
}
