import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_provider.dart';
import 'auth_user.dart' as auth;
import 'supabase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  const AuthService({required this.provider});

  factory AuthService.supabase() => AuthService(
        provider: SupabaseAuthProvider(),
      );

  @override
  auth.AuthUser? get currentUser => provider.currentUser;

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<auth.AuthUser> login(
          {required String email, required String password}) =>
      provider.login(email: email, password: password);

  @override
  Future<void> logout() => provider.logout();
}
