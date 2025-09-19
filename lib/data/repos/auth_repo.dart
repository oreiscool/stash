import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash/data/services/auth_service.dart';

part 'auth_repo.g.dart';

class AuthRepo {
  AuthRepo(this._authService);
  final AuthService _authService;

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) => _authService.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _authService.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _authService.signOut();
}

@riverpod
AuthService authService(Ref ref) => AuthService();

@riverpod
AuthRepo authRepo(Ref ref) => AuthRepo(ref.watch(authServiceProvider));
