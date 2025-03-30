import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ireport/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  final Map<String, dynamic>? userMetadata;
  const AuthState(
      {required this.isLoading,
      this.loadingText = 'Please wait a moment',
      this.userMetadata});
}

class AuthStateUnintialized extends AuthState {
  const AuthStateUnintialized({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthInitial extends AuthState {
  const AuthInitial({required super.isLoading});
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  final Map<String, dynamic> userData;
  const AuthStateLoggedIn(
      {required this.user,
      required super.isLoading,
      required this.userData});

  @override
  List<Object?> get props => [userMetadata];
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut(
      {required this.exception, required isLoading, String? loadingText})
      : super(isLoading: isLoading, loadingText: loadingText);

  @override
  List<Object?> get props => [exception, isLoading];
}
