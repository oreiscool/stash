import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash/data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_repo.g.dart';

// Keep alive so auth doesn't get disposed
@Riverpod(keepAlive: true)
class AuthRepo extends _$AuthRepo {
  late final AuthService _authService;

  @override
  Stream<User?> build() {
    _authService = AuthService();
    // Initialize Google Sign-In asynchronously on startup
    _authService.initialize();
    return _authService.authStateChanges;
  }

  // Sign Up
  Future<void> signUp(String email, String password) async {
    await _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign In
  Future<void> signIn(String email, String password) async {
    await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Google Sign-In (initialization handled internally by AuthService)
  Future<UserCredential?> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  // Silent Google Sign-In (for returning users)
  Future<GoogleSignInAccount?> attemptSilentGoogleSignIn() async {
    return await _authService.attemptSilentGoogleSignIn();
  }

  // Sign Out
  Future<void> signOut() async {
    await _authService.signOut();
  }
}

// Convenience provider for current user
@riverpod
User? currentUser(Ref ref) {
  final authState = ref.watch(authRepoProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, _) => null,
  );
}
