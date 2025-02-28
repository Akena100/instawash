import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instawash/configs/configs.dart';
import 'package:instawash/core/constants/assets.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/core/constants/strings.dart';

Widget noConnection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Space.yf(7),
      Center(child: Image.asset('assets/png/logo.png')),
      Space.yf(6),
      Text(
        "Internet Connection\nFailed",
        style: AppText.h1,
        textAlign: TextAlign.center,
      ),
      Space.yf(3),
      Center(
        child: SvgPicture.asset(
          AppAssets.noConnection,
          colorFilter:
              const ColorFilter.mode(AppColors.antiqueRuby, BlendMode.srcIn),
        ),
      ),
      Space.yf(1.5),
      Text(
        AppStrings.noConnection,
        textAlign: TextAlign.center,
        style: AppText.b2
            ?.copyWith(height: AppDimensions.normalize(.9), letterSpacing: 0),
      ),
    ],
  );
}
