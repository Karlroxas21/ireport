import 'package:flutter/material.dart';
import 'package:ireport/services/auth/supabase.dart';
import 'package:ireport/services/crud.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  late final CrudService _crudService = CrudService(SupabaseService().client);

  bool _isSubmitting = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/solana_logo.png',
                        height: 100,
                        width: 100,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "User Registration",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'First Name*',
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        hintText: "Enter your First Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                          return 'Special characters are not allowed';
                        }
                        return null;
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Last Name*',
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        hintText: "Enter your Last Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                          return 'Special characters are not allowed';
                        }
                        return null;
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Email*',
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Enter your Email",
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
                    const SizedBox(height: 10),
                    const Text(
                      'Phone Number*',
                    ),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        hintText: "Enter your phone number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        if (!RegExp(r'^09\d{9,10}$').hasMatch(value)) {
                            return 'Enter a valid phone number starting with 09 and containing 11 or 12 digits'
                              .replaceAllMapped(RegExp(r'.{1,40}(?:\s|$)'), (match) => '${match.group(0)}\n');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Pin*',
                    ),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return TextFormField(
                          controller: _pinController,
                          obscureText: !_isPasswordVisible,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Enter your pin",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a pin';
                            }
                            if (value != _confirmPinController.text) {
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
                    const Text(
                      'Confirm Pin*',
                    ),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return TextFormField(
                          obscureText: !_isConfirmPasswordVisible,
                          enableSuggestions: false,
                          autocorrect: false,
                          keyboardType: TextInputType.number,
                          controller: _confirmPinController,
                          decoration: InputDecoration(
                            hintText: "Confirm your pin",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a pin';
                            }
                            if (value != _confirmPinController.text) {
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            setState(() {
                              _isSubmitting = true;
                            });
                            final firstName = _firstNameController.text;
                            final lastName = _lastNameController.text;
                            final email = _emailController.text;
                            final phoneNumber = _phoneNumberController.text;
                            final password = _pinController.text;
                            final confirmPassword = _confirmPinController.text;

                            if (password != confirmPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Passwords do not match')));
                              return;
                            }

                            final userData = {
                              'first_name': firstName,
                              'last_name': lastName,
                              'email': email,
                              'phone_number': phoneNumber,
                              'password': password,
                            };

                            try {
                              final result =
                                  await _crudService.registerUser(userData);
                              if (result) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Confirmation email sent')),
                                );
                                _firstNameController.clear();
                                _lastNameController.clear();
                                _emailController.clear();
                                _phoneNumberController.clear();
                                _pinController.clear();
                                _confirmPinController.clear();
                                setState(() {});
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Failed to register')),
                                );
                              }
                            } on AuthException catch (e) {
                              if (e.message.contains('already registered') ||
                                  e.message
                                      .contains('user already registered')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Email is already registered.')),
                                );
                                _firstNameController.clear();
                                _lastNameController.clear();
                                _emailController.clear();
                                _phoneNumberController.clear();
                                _pinController.clear();
                                _confirmPinController.clear();
                                setState(() {});
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Authentication error: ${e.message}')),
                                );

                                _firstNameController.clear();
                                _lastNameController.clear();
                                _emailController.clear();
                                _phoneNumberController.clear();
                                _pinController.clear();
                                _confirmPinController.clear();
                                setState(() {});
                              }
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$error')),
                              );

                              _firstNameController.clear();
                              _lastNameController.clear();
                              _emailController.clear();
                              _phoneNumberController.clear();
                              _pinController.clear();
                              _confirmPinController.clear();
                              setState(() {});
                            } finally {
                              setState(() {
                                _isSubmitting = false;
                              });

                              _firstNameController.clear();
                              _lastNameController.clear();
                              _emailController.clear();
                              _phoneNumberController.clear();
                              _pinController.clear();
                              _confirmPinController.clear();
                              setState(() {});
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please check the form and try again')),
                            );
                          }
                        },
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Register',
                          style: TextStyle(color: Colors.black),
                        ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/login');
                  },
                  child: const Text(
                    'Already a user? Login',
                    style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline),
                  ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
