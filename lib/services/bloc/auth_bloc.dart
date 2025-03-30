import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:ireport/services/auth/auth_provider.dart';
import 'package:ireport/services/auth/supabase_auth_provider.dart';
import 'package:ireport/services/bloc/auth_event.dart';
import 'package:ireport/services/bloc/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUnintialized(isLoading: false)) {
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while I log you in'));
      final email = event.email;
      final password = event.password;

      try {
        final user = await provider.login(email: email, password: password);

        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString('user_data');
        
  

        if (userDataString != null) {
          final Map<String, dynamic> userDataMap = jsonDecode(userDataString);

          // Emit AuthStateLoggedIn with user metadata
          emit(AuthStateLoggedIn(
              user: user, isLoading: false, userData: userDataMap, ));
        } else {
          // If metadata is missing, emit a fallback state
          emit(AuthStateLoggedOut(
              exception: Exception('User metadata not found'),
              isLoading: false));
        }
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        // emit(AuthStateLoggedIn(user: user, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
    on<AuthEventLogout>((event, emit) async {
      try {
        await provider.logout();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
  }
}
