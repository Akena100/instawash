import 'package:flutter/material.dart';
import 'package:instawash/core/core.dart';

import 'package:instawash/configs/configs.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.secondaryColor,
        title: const Text(
          'PAGE',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...AppAssets.offersPng.map(
            (offer) => Padding(
              padding: Space.all(1.2, .5),
              child: Image.asset('assets/png/logo.png'),
            ),
          )
        ],
      ),
    );
  }
}
