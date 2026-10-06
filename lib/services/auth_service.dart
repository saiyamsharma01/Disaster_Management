import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  // Initialize Google Sign-In
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    try {
      await _googleSignIn.initialize();
      _isInitialized = true;
      debugPrint('✅ Google Sign-In initialized');
    } catch (e) {
      debugPrint('⚠️ Google Sign-In initialization failed: $e');
      _isInitialized = true; // Continue anyway, some platforms don't need init
    }
  }

  // Save/Update user data in Firestore
  Future<void> saveUserToFirestore(User? user, {String? customUsername}) async {
    if (user == null) return;
    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnap = await docRef.get();

      final username = customUsername ??
          user.displayName ??
          (user.email != null && user.email!.contains('@')
              ? user.email!.split('@').first
              : 'User');

      final Map<String, dynamic> data = {
        'uid': user.uid,
        'username': username,
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'lastLogin': FieldValue.serverTimestamp(),
      };

      if (!docSnap.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await docRef.set(data, SetOptions(merge: true));
      debugPrint('✅ User data saved to Firestore: ${user.uid}');
    } catch (e) {
      debugPrint('⚠️ Failed to save user to Firestore: $e');
    }
  }

  // Google Sign-In supporting both Web and Mobile
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential? credential;
      if (kIsWeb) {
        // On Web, use Firebase Auth's popup flow
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});
        credential = await _auth.signInWithPopup(provider);
      } else {
        // Ensure initialized before using
        await _ensureInitialized();

        // On mobile/desktop platforms - use authenticate()
        final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
          scopeHint: ['email'],
        );

        // Get auth credentials (synchronous property in v7)
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        // Create credential with idToken
        final authCred = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase
        credential = await _auth.signInWithCredential(authCred);
      }

      if (credential.user != null) {
        await saveUserToFirestore(credential.user);
      }

      return credential;
    } on GoogleSignInException catch (e) {
      debugPrint('GoogleSignInException: ${e.code.name}');
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in was canceled',
        );
      }
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      throw FirebaseAuthException(
        code: 'ERROR_GOOGLE_SIGN_IN',
        message: 'Failed to sign in with Google: $e',
      );
    }
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb && _isInitialized) {
        await _googleSignIn.disconnect();
      }
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
