import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class EmailConfirmed extends StatefulWidget {
  const EmailConfirmed({super.key});

  @override
  State<EmailConfirmed> createState() => _EmailConfirmedState();
}

class _EmailConfirmedState extends State<EmailConfirmed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Confirmed'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your email has been successfully confirmed!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                text: 'Login here',
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, '/login');
                  },
              ),
            ),
          ],
        ),
      ),
    );
  }
}