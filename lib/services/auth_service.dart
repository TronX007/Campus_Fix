import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/enums.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  // Initialize/retrieve user details from Firestore
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      _currentUser = null;
      return null;
    }

    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromMap(doc.data()!, doc.id);
        return _currentUser;
      }
    } catch (e) {
      // Return null or propagate exception
      rethrow;
    }

    return null;
  }

  Future<UserModel> login(String email, String password) async {
    final UserCredential credential = await _firebaseAuth
        .signInWithEmailAndPassword(
          email: email,
          password: password,
        )
        .timeout(const Duration(seconds: 10));

    if (credential.user == null) {
      throw FirebaseAuthException(code: 'user-not-found', message: 'User is null after login.');
    }

    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(credential.user!.uid)
        .get()
        .timeout(const Duration(seconds: 10));

    if (doc.exists && doc.data() != null) {
      _currentUser = UserModel.fromMap(doc.data()!, doc.id);
      return _currentUser!;
    } else {
      // Create user if doc doesn't exist (e.g. if created directly in Firebase Auth console)
      _currentUser = UserModel(
        uid: credential.user!.uid,
        name: credential.user!.displayName ?? email.split('@').first,
        email: email,
        role: email.contains('admin') ? UserRole.admin : UserRole.student,
        department: email.contains('admin') ? 'Administration' : 'General',
      );
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_currentUser!.uid)
          .set(_currentUser!.toMap())
          .timeout(const Duration(seconds: 10));
      return _currentUser!;
    }
  }

  Future<UserModel> register(
    String name,
    String email,
    String password,
    String rollNumber,
    String department,
  ) async {
    final UserCredential credential = await _firebaseAuth
        .createUserWithEmailAndPassword(
          email: email,
          password: password,
        )
        .timeout(const Duration(seconds: 10));

    if (credential.user == null) {
      throw FirebaseAuthException(code: 'user-not-found', message: 'User creation failed.');
    }

    await credential.user!.updateDisplayName(name).timeout(const Duration(seconds: 5));

    _currentUser = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      role: email.contains('admin') ? UserRole.admin : UserRole.student,
      rollNumber: rollNumber,
      department: department,
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(_currentUser!.uid)
        .set(_currentUser!.toMap())
        .timeout(const Duration(seconds: 10));

    return _currentUser!;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut().timeout(const Duration(seconds: 5));
    _currentUser = null;
  }
}

