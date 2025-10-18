import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServiceException implements Exception {
  final String message;
  AuthServiceException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isGoogleSignInInitialized = false;
  GoogleSignInAccount? _currentUser;

  // Initialize Google Sign-In asynchronously
  Future<void> initialize() async {
    if (_isGoogleSignInInitialized) return;

    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      throw AuthServiceException('Failed to initialize Google Sign-In: $e');
    }
  }

  // Ensure Google Sign-In is initialized before use
  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await initialize();
    }
  }

  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(e.message ?? 'An error occurred.');
    } catch (e) {
      throw AuthServiceException('An Unexpected Error Occurred: $e');
    }
  }

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException('Error signing in: ${e.message}');
    } catch (e) {
      throw AuthServiceException('An Unexpected Error Occurred: $e');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    try {
      // Check if platform supports authenticate method
      if (!_googleSignIn.supportsAuthenticate()) {
        throw AuthServiceException(
          'Google Sign-In is not supported on this platform.',
        );
      }

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Get authorization for Firebase
      final authClient = _googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email']);

      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;
      if (user != null) {
        // Check if user document exists in Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Update current user state
      _currentUser = googleUser;

      return userCredential;
    } on GoogleSignInException catch (e) {
      final message = _getGoogleSignInErrorMessage(e);
      throw AuthServiceException(message);
    } catch (e) {
      throw AuthServiceException('An Unexpected Error Occurred: $e');
    }
  }

  // Silent sign-in for returning users
  Future<GoogleSignInAccount?> attemptSilentGoogleSignIn() async {
    await _ensureGoogleSignInInitialized();

    try {
      final result = _googleSignIn.attemptLightweightAuthentication();

      // Handle both sync and async returns
      if (result is Future<GoogleSignInAccount?>) {
        _currentUser = await result;
      } else {
        _currentUser = result as GoogleSignInAccount?;
      }

      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();

      if (_isGoogleSignInInitialized) {
        await _googleSignIn.signOut();
      }

      _currentUser = null;
    } catch (e) {
      throw AuthServiceException('Error signing out: $e');
    }
  }

  String _getGoogleSignInErrorMessage(GoogleSignInException exception) {
    switch (exception.code.name) {
      case 'canceled':
        return 'Sign-in was cancelled. Please try again if you want to continue.';
      case 'interrupted':
        return 'Sign-in was interrupted. Please try again.';
      case 'clientConfigurationError':
        return 'There is a configuration issue with Google Sign-In. Please contact support.';
      case 'providerConfigurationError':
        return 'Google Sign-In is currently unavailable. Please try again later.';
      case 'uiUnavailable':
        return 'Google Sign-In interface is currently unavailable.';
      case 'userMismatch':
        return 'There was an issue with your account. Please sign out and try again.';
      case 'unknownError':
      default:
        return 'An unexpected error occurred: ${exception.description ?? "Unknown error"}';
    }
  }

  // Getters
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  GoogleSignInAccount? get currentGoogleUser => _currentUser;
  bool get isGoogleSignedIn => _currentUser != null;
}
