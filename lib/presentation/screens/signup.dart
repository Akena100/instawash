import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:instawash/configs/app_dimensions.dart';
import 'package:instawash/configs/app_typography.dart';
import 'package:instawash/configs/space.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/presentation/screens/email_verification.dart';
import 'package:instawash/presentation/widgets.dart';
import 'package:instawash/core/core.dart';
import '../../models/user_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isConnected = true; // Default to true, assuming there's a connection
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Validators _validators = Validators();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
  }

  Future<void> sendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  void navigateToEmailVerificationPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EmailVerificationPage()),
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create user with Firebase Auth
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;

        if (user != null) {
          // Send email verification
          await sendEmailVerification();
          String? token = await FirebaseMessaging.instance.getToken();

          // Create the UserModel
          if (token != null) {
            UserModel userModel = UserModel(
                fullName: _nameController.text.trim(),
                email: _emailController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
                id: user.uid,
                city: token,
                country: '',
                address: 'Active',
                role: 'Customer');

            // Save user to Firestore
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set(userModel.toDocument());
          }
          // Navigate to email verification page
          navigateToEmailVerificationPage();
        }
      } catch (e) {
        // Handle errors (e.g. weak password, email already in use)
        showErrorAuthBottomSheet(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : WillPopScope(
            onWillPop: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Are you sure?'),
                    content: Text('Do you want to exit the app?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text('No'),
                      ),
                    ],
                  );
                },
              ).then((value) {
                if (value == true) {
                  Navigator.of(context).pop(true);
                }
              });

              return false;
            },
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
                          authTopColumn(true),
                          customTextFormField(
                              label: "Name*",
                              svgUrl: AppAssets.username,
                              controller: _nameController,
                              validator: _validators.validateFirstName),
                          Space.yf(1.3),
                          customTextFormField(
                              label: "Email*",
                              svgUrl: AppAssets.email,
                              controller: _emailController,
                              validator: _validators.validateEmail),
                          Space.yf(1.3),
                          customTextFormField(
                              label: "Phone Number*",
                              svgUrl: AppAssets.phone,
                              controller: _phoneController,
                              validator: _validators.validatePhoneNumber),
                          Space.yf(1.3),
                          customTextFormField(
                              label: "Password*",
                              svgUrl: AppAssets.password,
                              controller: _passwordController,
                              validator: _validators.validatePassword),
                          Space.yf(1.3),
                          customTextFormField(
                            label: "Confirm Password*",
                            svgUrl: AppAssets.password,
                            controller: _confirmPasswordController,
                            validator: (value) =>
                                _validators.validateConfirmPassword(
                              _passwordController.text,
                              value,
                            ),
                          ),
                          Space.yf(1.5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: AppDimensions.normalize(10),
                                width: AppDimensions.normalize(10),
                                child: Material(
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.normalize(2)),
                                  color: AppColors.lightGrey,
                                  child: const Checkbox(
                                    value: true,
                                    onChanged: null,
                                    checkColor: Colors.purple,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ),
                              Space.xf(),
                              Text(
                                "I accept all Terms &\nConditions of Insta Wash.",
                                style: AppText.b1?.copyWith(
                                    color: AppColors.greyText, height: 1.5),
                              ).withDifferentStyle("Insta Wash",
                                  AppText.h3b!.copyWith(color: Colors.purple))
                            ],
                          ),
                          Space.yf(1.5),
                          customElevatedButton(
                            onTap: _signUp,
                            text: "SIGN UP",
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
              bottomNavigationBar: authBottomButton(
                true,
                () {
                  Navigator.of(context).pushNamed(AppRouter.login);
                },
              ),
            ),
          );
  }
}
