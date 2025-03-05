

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AuthEvent{
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogIn(this.email, this.password);
}

class AuthEventLogout extends AuthEvent {
  const AuthEventLogout();
}

// Nav bar
class HomePageEvent extends AuthEvent {
  const HomePageEvent();
}

class DashboardPageEvent extends AuthEvent {
  const DashboardPageEvent();
}

class ReportPageEvent extends AuthEvent {
  const ReportPageEvent();
}
