import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ireport/services/auth/auth_exceptions.dart';
import 'package:ireport/services/auth/supabase_auth_provider.dart';
import 'package:ireport/services/bloc/auth_bloc.dart';
import 'package:ireport/services/bloc/auth_event.dart';
import 'package:ireport/services/bloc/auth_state.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => __LoginViewState();
}

class __LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();

  late final _authProdiver = SupabaseAuthProvider();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  bool _isPinVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/solana_logo.png',
                      height: 100,
                      width: 100,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Username
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Email',
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _emailController,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Enter your email here",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a email';
                      }
                      if (!RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                          .hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  // Password
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Pin',
                    ),
                  ),
                  const SizedBox(height: 5),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return TextFormField(
                        controller: _pinController,
                        obscureText: !_isPinVisible,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter your pin",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPinVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPinVisible = !_isPinVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a pin';
                          }
                          if (value != _pinController.text) {
                            return 'Pin do not match';
                          }
                          if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                            return 'Pin must be exactly 6 digits';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  BlocListener<AuthBloc, auth.AuthState>(
                    listener: (context, state) async {},
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    side: const BorderSide(color: Colors.black),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      final email = _emailController.text;
                                      final pin = _pinController.text;

                                      try {
                                        final result = await _authProdiver
                                            .login(email: email, password: pin);
                                        if (result != AuthException) {
                                          context
                                              .read<AuthBloc>()
                                              .add(AuthEventLogIn(email, pin));

                                          final session = Supabase.instance
                                              .client.auth.currentSession;

                                          if (session != null) {
                                            final prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            await prefs.setString(
                                                'supabase_session',
                                                session.toJson().toString());

                                            final metadataString = prefs
                                                .getString('user_metadata');
                                            final Map<String, dynamic>
                                                metadataMap =
                                                jsonDecode(metadataString!);
                                            final String role =
                                                metadataMap['role'] ?? '';

                                            if (role == 'user') {
                                              context.go('/user-home');
                                            } else {
                                              context.go('/admin-home');
                                            }
                                          }

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text("Login Successful")),
                                          );

                                          _emailController.clear();
                                          _pinController.clear();
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text("Login Failed")),
                                          );
                                        }
                                      } on InvalidCredentialsException {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Invalid login credentials")));
                                      } on UserNotFoundAuthException {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content:
                                                    Text("User not found")));
                                      } on RateLimitExceededException {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Limit exceed. Try again later")));
                                      } on EmailNotConfirmedAuthException {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Email not confirmed. Check your inbox")));
                                      } catch (error) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'An error occured12. $error')));
                                      } finally {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                                context.pushNamed('/send-forgot-password');
                            //   Navigator.of(context)
                            //       .pushNamed('/forgot-password');
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
