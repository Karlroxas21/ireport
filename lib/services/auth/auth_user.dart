import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final String id;
  final String email;

  const AuthUser({
    required this.id,
    required this.email,
  });

  factory AuthUser.fromSupabaseUser(User user) => AuthUser(
        email: user.email ?? '',
        id: user.id,
      );
}
