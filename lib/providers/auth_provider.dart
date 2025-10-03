import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import 'dart:async';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _isInitialized = false;
  StreamSubscription<User?>? _authSubscription;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isInitialized => _isInitialized;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isParticipant => _user?.isParticipant ?? false;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    debugPrint('🔄 AuthProvider: Initializing auth listener...');
    
    // Check current auth state immediately
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      debugPrint('🔄 AuthProvider: Found existing user session: ${currentUser.uid}');
      _loadUserProfile(currentUser.uid).then((_) {
        _markAsInitialized();
      }).catchError((e) {
        debugPrint('❌ AuthProvider: Initial load error: $e');
        _setUnauthenticated();
        _markAsInitialized();
      });
    } else {
      debugPrint('🔄 AuthProvider: No existing user session');
      _setUnauthenticated();
      _markAsInitialized();
    }
    
    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen(
      (User? firebaseUser) async {
        debugPrint('🔄 AuthProvider: Auth state changed - User: ${firebaseUser?.uid}');
        
        try {
          if (firebaseUser != null) {
            await _loadUserProfile(firebaseUser.uid);
          } else {
            _setUnauthenticated();
          }
        } catch (e) {
          debugPrint('❌ AuthProvider: Auth state change error: $e');
          _setError('Authentication error: ${e.toString()}');
        }
      },
      onError: (error) {
        debugPrint('❌ AuthProvider: Auth stream error: $error');
        _setError('Authentication stream error: ${error.toString()}');
        if (!_isInitialized) {
          _markAsInitialized();
        }
      },
    );

    // Safety timeout - ensure we initialize even if something goes wrong
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isInitialized) {
        debugPrint('⚠️ AuthProvider: Initialization timeout - forcing initialization');
        if (_status == AuthStatus.initial || _status == AuthStatus.loading) {
          _setUnauthenticated();
        }
        _markAsInitialized();
      }
    });
  }

  void _markAsInitialized() {
    if (!_isInitialized) {
      debugPrint('✅ AuthProvider: Marking as initialized (Status: $_status)');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      debugPrint('🔄 AuthProvider: Loading user profile for $uid');
      
      final userModel = await _firestoreService.getUser(uid);
      if (userModel != null) {
        debugPrint('✅ AuthProvider: User profile loaded successfully');
        _user = userModel;
        _status = AuthStatus.authenticated;
        notifyListeners();
        
        // Update last active in background
        _firestoreService.updateUserLastActive(uid).catchError((e) {
          debugPrint('⚠️ AuthProvider: Failed to update last active: $e');
        });
      } else {
        debugPrint('❌ AuthProvider: User profile not found');
        _setUnauthenticated();
      }
    } catch (e) {
      debugPrint('❌ AuthProvider: Failed to load user profile: $e');
      _setError('Failed to load user profile: ${e.toString()}');
      _setUnauthenticated();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      debugPrint('🔄 AuthProvider: Starting Google sign in...');
      _setStatus(AuthStatus.loading);
      _clearError();
      
      final userModel = await _authService.signInWithGoogle();
      if (userModel != null) {
        debugPrint('✅ AuthProvider: Google sign in successful');
        _user = userModel;
        _setStatus(AuthStatus.authenticated);
      } else {
        debugPrint('❌ AuthProvider: Google sign in cancelled');
        _setError('Sign in was cancelled');
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      debugPrint('❌ AuthProvider: Google sign in failed: $e');
      _setError('Sign in failed: ${e.toString()}');
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('🔄 AuthProvider: Signing out...');
      _setStatus(AuthStatus.loading);
      await _authService.signOut();
      _setUnauthenticated();
      debugPrint('✅ AuthProvider: Sign out successful');
    } catch (e) {
      debugPrint('❌ AuthProvider: Sign out failed: $e');
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
      debugPrint('Failed to update profile: $e');
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
      debugPrint('Failed to switch role: $e');
      _setError('Failed to switch role: ${e.toString()}');
    }
  }

  Future<void> deleteAccount() async {
    try {
      _setStatus(AuthStatus.loading);
      await _authService.deleteAccount();
      _setUnauthenticated();
    } catch (e) {
      debugPrint('Failed to delete account: $e');
      _setError('Failed to delete account: ${e.toString()}');
    }
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setUnauthenticated() {
    debugPrint('🔄 AuthProvider: Setting unauthenticated');
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

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // Force initialization for testing/debugging
  void forceInitialization() {
    if (!_isInitialized) {
      debugPrint('⚡ AuthProvider: Force initializing...');
      if (_status == AuthStatus.initial) {
        _setUnauthenticated();
      }
      _markAsInitialized();
    }
  }
}