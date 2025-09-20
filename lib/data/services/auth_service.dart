import 'package:firebase_auth/firebase_auth.dart';

class AuthServiceException implements Exception {
  final String message;
  AuthServiceException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
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

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
