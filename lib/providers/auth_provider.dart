import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/app_user.dart';
import '../services/firebase_service.dart';


class AuthProvider extends ChangeNotifier {
  final FirebaseService _service;
  StreamSubscription<fb.User?>? _authSub;
  StreamSubscription<AppUser?>? _profileSub;

  AppUser? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  AuthProvider(this._service) {
    _authSub = _service.authStateChanges.listen(_onAuthChanged);
  }

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;

  void _onAuthChanged(fb.User? user) {
    _profileSub?.cancel();
    if (user == null) {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return;
    }
    _profileSub = _service.userProfileStream(user.uid).listen(
      (profile) {
        _currentUser = profile;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        notifyListeners();
        // ignore: avoid_print
        print('AuthProvider profile stream error: $e');
      },
    );
  }

  Future<bool> signIn(String email, String password) async {
    _errorMessage = null;
    try {
      await _service.signIn(email, password);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _errorMessage = null;
    try {
      final cred = await _service.signUp(email, password);
      final uid = cred.user!.uid;
      final profile = AppUser(
        uid: uid,
        fullName: fullName,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );
      await _service.createUserProfile(profile);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() => _service.signOut();

  String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}