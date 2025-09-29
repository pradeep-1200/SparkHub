import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

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
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
      
      final User? user = userCredential.user;
      
      if (user != null) {
        // Check if user exists in Firestore
        final existingUser = await _firestoreService.getUser(user.uid);
        
        if (existingUser != null) {
          // Update last active
          await _firestoreService.updateUserLastActive(user.uid);
          return existingUser;
        } else {
          // Create new user
          final newUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? 'User',
            email: user.email ?? '',
            role: 'participant', // Default role
            createdAt: DateTime.now(),
            lastActive: DateTime.now(),
            profileImageUrl: user.photoURL,
          );
          
          await _firestoreService.createUser(newUser);
          return newUser;
        }
      }
      
      return null;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestoreService.deleteUser(user.uid);
        
        // Delete Firebase Auth account
        await user.delete();
        
        // Sign out from Google
        await _googleSignIn.signOut();
      }
    } catch (e) {
      print('Delete account error: $e');
      rethrow;
    }
  }
}
