import 'package:flutter/material.dart';
import 'package:instawash/core/router/app_router.dart';

import '../../core/constants/colors.dart';

class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text('Email Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Check your email for a verification link.',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Optionally, add a button to manually trigger email verification again
                // You can call the sendEmailVerification function here again
                // sendEmailVerification();
              },
              child: const Text('Resend Verification Email'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the login screen
                Navigator.of(context).pushNamed(AppRouter.root);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
