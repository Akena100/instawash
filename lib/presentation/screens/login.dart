import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/presentation/screens/forgot_password.dart';
import 'package:instawash/presentation/widgets.dart';
import 'package:instawash/core/core.dart';

import '../../configs/configs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Validators _validators = Validators();

  bool _isPasswordHidden = true;
  bool _isConnected = true;

  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  void initState() {
    _checkInternetConnection();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = true}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Logging in..."),
          ],
        ),
      ),
    );
  }

  void saveDeviceToken() async {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      String customerId = FirebaseAuth.instance.currentUser!.uid;
      debugPrint("bbbbbbbbbb $token");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(customerId)
          .update({
        'city': token, // Store user's device token
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    _showLoadingDialog();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      saveDeviceToken();
      Navigator.of(context).pop();
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.root,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
          _showSnackbar("Incorrect email or password.");
          break;
        case 'network-request-failed':
          _showSnackbar("No internet connection.");
          break;
        case 'invalid-email':
          _showSnackbar('The email address is invalid.');
          break;
        case 'user-disabled':
          _showSnackbar('This user account has been disabled.');
          break;
        case 'too-many-requests':
          _showSnackbar("Too many attempts. Try again later.");
          break;
        default:
          _showSnackbar("Error: ${e.message}");
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showSnackbar("An unexpected error occurred.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : Theme(
            data: ThemeData(
              textTheme: TextTheme(
                titleSmall: TextStyle(color: Colors.white),
              ),
            ),
            child: Scaffold(
              backgroundColor: AppColors.bgColor,
              body: SingleChildScrollView(
                child: SafeArea(
                  minimum: EdgeInsets.only(top: AppDimensions.normalize(20)),
                  child: Padding(
                    padding: Space.hf(1.3),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          authTopColumn(false),
                          customTextFormField(
                            label: "Email Address*",
                            svgUrl: AppAssets.email,
                            controller: _emailController,
                            validator: _validators.validateEmail,
                          ),
                          Space.yf(1.3),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              errorStyle:
                                  AppText.l1b?.copyWith(color: Colors.red),
                              errorMaxLines: 3,
                              labelStyle: AppText.b1
                                  ?.copyWith(color: AppColors.greyText),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.lightGrey),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.antiqueRuby),
                              ),
                              labelText: "Password*",
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.blue,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordHidden
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordHidden = !_isPasswordHidden;
                                  });
                                },
                              ),
                            ),
                            controller: _passwordController,
                            obscureText: _isPasswordHidden,
                            validator: _validators.validatePassword,
                          ),
                          Space.yf(.3),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Get.to(() => const ForgotPasswordPage());
                              },
                              child: Text(
                                "Forgot Password?",
                                style: AppText.b2,
                              ),
                            ),
                          ),
                          Space.yf(2.5),
                          customElevatedButton(
                            onTap: _login,
                            text: "Login".toUpperCase(),
                            heightFraction: 20,
                            width: double.infinity,
                            color: AppColors.commonAmber,
                          ),
                          Space.yf(2.5),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: authBottomButton(false, () {
                Navigator.of(context).pushNamed(AppRouter.signup);
              }),
            ),
          );
  }
}
