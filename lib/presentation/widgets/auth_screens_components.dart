import 'package:flutter/material.dart';

import '../../configs/configs.dart';

Widget authTopColumn(bool isFromSignUp) {
  return Column(
    children: [
      Space.yf(2.5),
      CircleAvatar(
        radius: 60,
        child: Image.asset('assets/png/logo.png'),
      ),
      Space.yf(3),
      Text(
        isFromSignUp ? "SIGN UP" : "SIGN IN",
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
      Space.yf(2.5),
    ],
  );
}

Widget authBottomButton(bool isFromSignUp, void Function()? onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: AppDimensions.normalize(35),
      decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.normalize(7.5)),
              topRight: Radius.circular(AppDimensions.normalize(7.5)))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isFromSignUp
                ? "Already have an account?"
                : "Don’t have an account?",
            style: AppText.b2?.copyWith(color: Colors.white),
          ),
          Space.yf(.5),
          Text(
            isFromSignUp ? "Login".toUpperCase() : "SIGN UP",
            style: AppText.h3b?.copyWith(color: Colors.white),
          ),
        ],
      ),
    ),
  );
}
