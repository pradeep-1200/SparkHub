import 'package:flutter_test/flutter_test.dart';
import 'package:sparkhub/models/user_model.dart';
import 'package:sparkhub/providers/auth_provider.dart';

// Create a simple mock without external dependencies
class MockAuthProvider extends AuthProvider {
  bool _shouldSucceed = true;
  UserModel? _mockUser;

  void setShouldSucceed(bool value) => _shouldSucceed = value;
  void setMockUser(UserModel? user) => _mockUser = user;

  @override
  Future<void> signInWithGoogle() async {
    if (_shouldSucceed && _mockUser != null) {
      user = _mockUser;
      status = AuthStatus.authenticated;
    } else {
      status = AuthStatus.error;
      errorMessage = 'Mock sign in failed';
    }
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    user = null;
    status = AuthStatus.unauthenticated;
    errorMessage = null;
    notifyListeners();
  }
}

void main() {
  group('AuthProvider', () {
    late MockAuthProvider authProvider;

    setUp(() {
      authProvider = MockAuthProvider();
    });

    test('should initialize with initial state', () {
      expect(authProvider.status, AuthStatus.initial);
      expect(authProvider.user, null);
      expect(authProvider.isAuthenticated, false);
    });

    test('should handle successful sign in', () async {
      final testUser = UserModel(
        uid: 'test-uid',
        name: 'Test User',
        email: 'test@example.com',
        role: 'participant',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      authProvider.setShouldSucceed(true);
      authProvider.setMockUser(testUser);

      await authProvider.signInWithGoogle();

      expect(authProvider.status, AuthStatus.authenticated);
      expect(authProvider.user, testUser);
      expect(authProvider.isAuthenticated, true);
    });

    test('should handle sign in error', () async {
      authProvider.setShouldSucceed(false);

      await authProvider.signInWithGoogle();

      expect(authProvider.status, AuthStatus.error);
      expect(authProvider.errorMessage, isNotNull);
      expect(authProvider.isAuthenticated, false);
    });

    test('should handle sign out', () async {
      // First sign in
      final testUser = UserModel(
        uid: 'test-uid',
        name: 'Test User',
        email: 'test@example.com',
        role: 'participant',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      authProvider.setShouldSucceed(true);
      authProvider.setMockUser(testUser);
      await authProvider.signInWithGoogle();

      // Then sign out
      await authProvider.signOut();

      expect(authProvider.status, AuthStatus.unauthenticated);
      expect(authProvider.user, null);
      expect(authProvider.isAuthenticated, false);
    });

    test('should validate admin role correctly', () async {
      final adminUser = UserModel(
        uid: 'admin-uid',
        name: 'Admin User',
        email: 'admin@example.com',
        role: 'admin',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      authProvider.setShouldSucceed(true);
      authProvider.setMockUser(adminUser);
      await authProvider.signInWithGoogle();

      expect(authProvider.isAdmin, true);
      expect(authProvider.user!.isAdmin, true);
    });

    test('should validate participant role correctly', () async {
      final participantUser = UserModel(
        uid: 'participant-uid',
        name: 'Participant User',
        email: 'participant@example.com',
        role: 'participant',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      authProvider.setShouldSucceed(true);
      authProvider.setMockUser(participantUser);
      await authProvider.signInWithGoogle();

      expect(authProvider.isAdmin, false);
      expect(authProvider.user!.isParticipant, true);
    });
  });
}
