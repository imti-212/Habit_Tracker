import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_tracker/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _auth.currentUser != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      await _loadUserData(firebaseUser.uid);
    } else {
      _user = null;
      notifyListeners();
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data()!, doc.id);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to load user data: $e';
      notifyListeners();
    }
  }

  Future<bool> register({
    required String displayName,
    required String email,
    required String password,
    String? gender,
    DateTime? dateOfBirth,
    double? height,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate password
      if (password.length < 8) {
        throw 'Password must be at least 8 characters long';
      }
      if (!password.contains(RegExp(r'[A-Z]'))) {
        throw 'Password must contain at least one uppercase letter';
      }
      if (!password.contains(RegExp(r'[a-z]'))) {
        throw 'Password must contain at least one lowercase letter';
      }
      if (!password.contains(RegExp(r'[0-9]'))) {
        throw 'Password must contain at least one number';
      }

      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw 'Failed to create user';

      // Create user document in Firestore
      final userModel = UserModel(
        id: user.uid,
        displayName: displayName,
        email: email,
        gender: gender,
        dateOfBirth: dateOfBirth,
        height: height,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());

      _user = userModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save login state to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userEmail');
      
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? gender,
    DateTime? dateOfBirth,
    double? height,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = _user!.copyWith(
        displayName: displayName ?? _user!.displayName,
        gender: gender ?? _user!.gender,
        dateOfBirth: dateOfBirth ?? _user!.dateOfBirth,
        height: height ?? _user!.height,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_user!.id)
          .update(updatedUser.toMap());

      _user = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
