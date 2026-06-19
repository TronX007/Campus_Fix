import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  Future<void> checkCurrentUser() async {
    _setLoading(true);
    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String email, String password, {required String selectedRole}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final userModel = await _authService.login(email, password);
      
      // Role Mismatch Check
      if (userModel.role.name != selectedRole) {
        await _authService.logout();
        _user = null;
        if (selectedRole == 'admin') {
          throw FirebaseAuthException(code: 'role-mismatch-admin', message: 'This account does not have administrator access.');
        } else {
          throw FirebaseAuthException(code: 'role-mismatch-student', message: 'Please use Admin Login.');
        }
      }

      _user = userModel;
      notifyListeners();
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String name, String email, String password, String rollNumber, String department) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _user = await _authService.register(name, email, password, rollNumber, department);
      notifyListeners();
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
    } finally {
      _user = null;
      notifyListeners();
      _setLoading(false);
    }
  }

  String _parseError(dynamic e) {
    if (e is TimeoutException) {
      return "Operation timed out. Please check database connectivity.";
    }
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return "Invalid email or password.";
        case 'email-already-in-use':
          return "Email already exists.";
        case 'invalid-email':
          return "The email address is invalid.";
        case 'network-request-failed':
          return "Network connection lost. Please check your internet.";
        case 'role-mismatch-student':
        case 'role-mismatch-admin':
          return e.message ?? "Role mismatch error.";
        default:
          return e.message ?? "Authentication failed.";
      }
    }
    if (e is FirebaseException) {
      return e.message ?? "A database error occurred.";
    }
    return e.toString();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}


