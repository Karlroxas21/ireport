import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ireport/services/auth/auth_exceptions.dart';
import 'package:ireport/services/auth/supabase_auth_provider.dart';
import 'package:ireport/services/bloc/auth_bloc.dart';
import 'package:ireport/services/bloc/auth_event.dart';
import 'package:ireport/services/bloc/auth_state.dart' as auth;
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => __LoginViewState();
}

class __LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final _authProdiver = SupabaseAuthProvider();
  final _formKey = GlobalKey<FormState>();

  // void _login() async {
  //   final email = _emailController.text;
  //   final password = _passwordController.text;
  //   try {
  //     final user = await _authProvider.login(email, password);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Login Successful")),
  //     );

  //     // Redirect to admin_home_view.dart and set isLoggedIn to true
  //     Navigator.of(context).pushReplacementNamed('/admin-home');
  //     // Assuming you have a global state or a provider to set isLoggedIn
  //     // For example, using a provider:
  //     // Provider.of<AuthProvider>(context, listen: false).setLoggedIn(true);

  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Login Failed: $e")),
  //     );
  //   }
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Username',
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
                    'Password',
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: "Enter your password here",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BlocListener<AuthBloc, auth.AuthState>(
                  listener: (context, state) async {},
                  child: Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final email = _emailController.text;
                          final password = _passwordController.text;

                          try {
                            final result = await _authProdiver.login(
                                email: email, password: password);
                            if (result != AuthException) {
                              ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Login Successful")),
                              );

                              _emailController.clear();
                              _passwordController.clear();

                              Navigator.of(context).pushNamedAndRemoveUntil(
                              '/admin-home',
                              (Route<dynamic> route) => false,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Login Failed")),
                              );
                            }
                          } on InvalidCredentialsException {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Invalid login credentials")));
                          } on UserNotFoundAuthException {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("User not found")));
                          } on RateLimitExceededException {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Limit exceed. Try again later")));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "An error occured. Try again later")));
                          }
                        }
                        // context
                        //     .read<AuthBloc>()
                        //     .add(AuthEventLogIn(email, password));
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
