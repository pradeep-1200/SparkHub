import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isParticipant => _user?.isParticipant ?? false;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserProfile(firebaseUser.uid);
      } else {
        _setUnauthenticated();
      }
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      _setStatus(AuthStatus.loading);
      final userModel = await _firestoreService.getUser(uid);
      
      if (userModel != null) {
        _user = userModel;
        _setStatus(AuthStatus.authenticated);
        await _firestoreService.updateUserLastActive(uid);
      } else {
        _setUnauthenticated();
      }
    } catch (e) {
      _setError('Failed to load user profile: ${e.toString()}');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _setStatus(AuthStatus.loading);
      _clearError();

      final userModel = await _authService.signInWithGoogle();
      
      if (userModel != null) {
        _user = userModel;
        _setStatus(AuthStatus.authenticated);
      } else {
        _setError('Sign in was cancelled');
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      _setError('Sign in failed: ${e.toString()}');
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  Future<void> signOut() async {
    try {
      _setStatus(AuthStatus.loading);
      await _authService.signOut();
      _setUnauthenticated();
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
  }) async {
    if (_user == null) return;

    try {
      final updatedUser = _user!.copyWith(
        name: name,
        profileImageUrl: profileImageUrl,
        preferences: preferences,
      );

      await _firestoreService.updateUser(updatedUser);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
    }
  }

  Future<void> switchUserRole(String newRole) async {
    if (_user == null || !isAdmin) return;

    try {
      final updatedUser = _user!.copyWith(role: newRole);
      await _firestoreService.updateUser(updatedUser);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError('Failed to switch role: ${e.toString()}');
    }
  }

  Future<void> deleteAccount() async {
    try {
      _setStatus(AuthStatus.loading);
      await _authService.deleteAccount();
      _setUnauthenticated();
    } catch (e) {
      _setError('Failed to delete account: ${e.toString()}');
    }
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setUnauthenticated() {
    _status = AuthStatus.unauthenticated;
    _user = null;
    _clearError();
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = AuthStatus.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
