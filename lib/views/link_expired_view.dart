import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LinkExpireView extends StatefulWidget {
  const LinkExpireView({super.key});

  @override
  State<LinkExpireView> createState() => _LinkExpireViewState();
}

class _LinkExpireViewState extends State<LinkExpireView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Expired'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'The link you open is expired.',
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
                    context.pushNamed('/login');
                    // Navigator.pushNamed(context, '/login');
                  },
              ),
            ),
          ],
        ),
      ),
    );
  }
}