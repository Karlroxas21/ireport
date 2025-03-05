import 'package:ireport/services/auth/auth_exceptions.dart';
import 'package:ireport/services/auth/auth_provider.dart';
import 'package:ireport/services/auth/auth_user.dart' as auth;
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, AuthResponse, SupabaseClient, User;
import 'supabase.dart';

class SupabaseAuthProvider implements AuthProvider {
  final SupabaseClient _supabase = SupabaseService().client;

  //  NO sign up atm
  // Future<AuthResponse> signUp(String email, String password) async {
  //   final response =
  //       await _supabase.auth.signUp(email: email, password: password);
  //   return response;
  // }

  @override
  Future<void> initialize() async {
    await SupabaseService.initialize();
  }

  @override
  auth.AuthUser? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return auth.AuthUser.fromSupabaseUser(user);
    }
    return null;
  }

  @override
  Future<auth.AuthUser> login(
      {required String email, required String password}) async {
    try {
      final response = await _supabase.auth
          .signInWithPassword(email: email, password: password);

      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw InvalidCredentialsException();
      } else if (e.message.contains('User not found')) {
        throw UserNotFoundAuthException();
      } else if (e.message.contains('Too many requests')) {
        throw RateLimitExceededException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logout() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await _supabase.auth.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
}
