import 'auth_user.dart';

abstract class AuthProvider{
  Future<void> initialize();

  AuthUser? get currentUser;

  Future<AuthUser> login({required String email, required String password});

  Future<void> logout();

}