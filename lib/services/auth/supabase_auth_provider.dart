import 'dart:convert';

import 'package:ireport/services/auth/auth_exceptions.dart';
import 'package:ireport/services/auth/auth_provider.dart';
import 'package:ireport/services/auth/auth_user.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
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

  Map<String, dynamic> mapUserToJson(User user) {
    return {
      'id': user.id,
      'aud': user.aud,
      'role': user.role,
      'email': user.email,
      'emailConfirmedAt': user.emailConfirmedAt,
      'phone': user.phone,
      'lastSignInAt': user.lastSignInAt,
      'appMetadata': user.appMetadata,
      'userMetadata': user.userMetadata,
      'identities': user.identities?.map((identity) {
        return {
          'identityId': identity.identityId,
          'id': identity.id,
          'userId': identity.userId,
          'identityData': identity.identityData,
          'provider': identity.provider,
          'lastSignInAt': identity.lastSignInAt,
          'createdAt': identity.createdAt,
          'updatedAt': identity.updatedAt,
        };
      }).toList(),
      'createdAt': user.createdAt,
      'updatedAt': user.updatedAt,
    };
  }

  @override
  Future<auth.AuthUser> login(
      {required String email, required String password}) async {
    try {
      final response = await _supabase.auth
          .signInWithPassword(email: email, password: password);

      final user = currentUser;
      if (user != null) {
        final userData = _supabase.auth.currentSession?.user;

        final userMap = mapUserToJson(userData!);
        final metadataString = jsonEncode(userMap['userMetadata']);

        final String userJson = jsonEncode(userMap);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', userJson);
        await prefs.setString('user_metadata', metadataString);
        await prefs.setString('user_id', userMap['id']);

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
      } else if (e.message.contains('Email not confirmed')) {
        throw EmailNotConfirmedAuthException();
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
