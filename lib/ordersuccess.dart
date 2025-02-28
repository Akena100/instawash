import 'package:flutter/material.dart';
import 'package:instawash/core/router/app_router.dart';

import 'package:get/get.dart';

class OrderSuccessfulPage extends StatelessWidget {
  const OrderSuccessfulPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/png/success_image.png', // Add your image to the assets folder
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Your order was successful!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Get.offAllNamed(AppRouter.root);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
