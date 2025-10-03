import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  
  // Add the missing instance getter
  static FirebaseAuthService get instance => _instance;
  
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService firestoreService = FirestoreService.instance;

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential result = await _auth.signInWithCredential(credential);
      final User? user = result.user;

      if (user != null) {
        // Check if user exists in Firestore
        UserModel? userModel = await firestoreService.getUser(user.uid);
        
        if (userModel == null) {
          // Create new user profile
          userModel = UserModel(
            uid: user.uid,
            name: user.displayName ?? 'Unknown User',
            email: user.email ?? '',
            role: 'participant', // Default role
            createdAt: DateTime.now(),
            lastActive: DateTime.now(),
            profileImageUrl: user.photoURL,
          );
          await firestoreService.createUser(userModel);
        } else {
          // Update last active
          await firestoreService.updateUserLastActive(user.uid);
        }
        
        return userModel;
      }
    } catch (e) {
      print('Error during Google sign in: $e');
      rethrow;
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Delete account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Delete user data from Firestore
      await firestoreService.deleteUser(user.uid);
      
      // Delete Firebase Auth account
      await user.delete();
      
      // Sign out from Google
      await _googleSignIn.signOut();
    }
  }

  // Re-authenticate user (required for sensitive operations)
  Future<void> reauthenticateWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Re-authentication cancelled');

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final user = _auth.currentUser;
    if (user != null) {
      await user.reauthenticateWithCredential(credential);
    }
  }
}
