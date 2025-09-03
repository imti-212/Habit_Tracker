import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = false;

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString('themeMode');
      
      if (themeString != null) {
        switch (themeString) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          default:
            _themeMode = ThemeMode.system;
        }
        notifyListeners();
      }

      // Sync with Firebase if user is logged in
      final user = _auth.currentUser;
      if (user != null) {
        await _syncThemeWithFirebase();
      }
    } catch (e) {
      // Ignore errors for theme loading
    }
  }

  Future<void> _syncThemeWithFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('preferences')
          .doc('theme')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final firebaseTheme = data['themeMode'];
        
        if (firebaseTheme != null) {
          switch (firebaseTheme) {
            case 'light':
              _themeMode = ThemeMode.light;
              break;
            case 'dark':
              _themeMode = ThemeMode.dark;
              break;
            default:
              _themeMode = ThemeMode.system;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      // Ignore Firebase sync errors
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    // Save to local storage
    final prefs = await SharedPreferences.getInstance();
    String themeString;
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }
    await prefs.setString('themeMode', themeString);

    // Sync with Firebase
    await _saveThemeToFirebase(themeString);
  }

  Future<void> _saveThemeToFirebase(String themeString) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('preferences')
          .doc('theme')
          .set({
        'themeMode': themeString,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Ignore Firebase save errors
    }
  }

  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newMode);
  }
}
