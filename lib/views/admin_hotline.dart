import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminHotline extends StatelessWidget {
  const AdminHotline({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 8, right: 8),
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child:  Column(
            children: [
            const Text(
              'Solana Police Station Hotline',
              style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
              'Phone Number:',
              style: TextStyle(
                fontSize: 16,
              ),
              ),
            ),
            GestureDetector(
              onTap: () {
              launchUrl(Uri.parse('tel:09175932574'));
              launch('tel:09175932574');
              },
              child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '09175932574',
                style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                decoration: TextDecoration.underline,
                ),
              ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
              launchUrl(Uri.parse('tel:09985985218'));
              launch('tel:09985985218');
              },
              child: const Align(
              alignment:  Alignment.centerLeft,
              child: Text(
                '09985985218',
                style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                decoration: TextDecoration.underline,
                ),
              ),
              ),
            ),
            ],
        )
        ),
    );
  }
}