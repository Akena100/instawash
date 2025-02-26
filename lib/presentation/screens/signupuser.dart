import 'dart:io'; // Add this import to work with the File class
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:instawash/configs/app_dimensions.dart';

import 'package:instawash/configs/space.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';

import 'package:instawash/presentation/screens/email_verify.dart';
import 'package:instawash/presentation/widgets.dart';
import 'package:instawash/core/core.dart';
import '../../models/user_model.dart';

class SignUpScreen2 extends StatefulWidget {
  final UserModel? userModel; // Optionally pass in a user model for editing

  const SignUpScreen2({super.key, this.userModel});

  @override
  State<SignUpScreen2> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen2> {
  bool _isConnected = true; // Default to true, assuming there's a connection
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String idX = '';
  final _formKey = GlobalKey<FormState>();
  final Validators _validators = Validators();

  // Image variables
  XFile? _imageFile;
  String? _imageUrl;

  // Role Dropdown Variables
  final List<String> _roles = [
    'Administrator',
    'Head Of Department',
    'Driver',
    'Manager',
    'Customer',
    'Technician',
    'Customer Care',
    'Receptionist'
  ]; // Service delivery company roles
  String? _selectedRole = 'Customer'; // Default role

  bool _isEditing = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.userModel != null) {
      _isEditing = true;
      _nameController.text = widget.userModel!.fullName;
      _emailController.text = widget.userModel!.email;
      _phoneController.text = widget.userModel!.phoneNumber;
      _selectedRole = widget.userModel!.role;
      _imageUrl = widget.userModel!.imageUrl;
      idX = widget.userModel!.id;
    }
    _checkInternetConnection();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = pickedFile;
      }
    });
  }

  Future<String> _uploadImageToStorage(XFile image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(File(image.path)); // Convert to File before uploading
      final imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      throw Exception("Error uploading image: $e");
    }
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

          // Upload image to Firebase Storage if selected
          if (_imageFile != null) {
            _imageUrl = await _uploadImageToStorage(_imageFile!);
          }

          // Create the UserModel
          UserModel userModel = UserModel(
              fullName: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              id: user.uid,
              city: '',
              country: '',
              address: 'Active',
              role: _selectedRole ?? 'Customer', // Use selectedRole here
              imageUrl: _imageUrl ?? '');

          // Save user to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(userModel.toDocument());

          // Navigate to email verification page
          navigateToEmailVerificationPage();
        }
      } catch (e) {
        // Handle errors (e.g. weak password, email already in use)
        showErrorAuthBottomSheet(context);
      }
    }
  }

  Future<void> _updateUserDetails() async {
    if (_formKey.currentState!.validate()) {
      try {
        show();
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Update user details in Firestore
          if (_imageFile != null) {
            _imageUrl = await _uploadImageToStorage(_imageFile!);
          }

          UserModel updatedUserModel = UserModel(
              fullName: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              id: user.uid,
              city: '',
              country: '',
              address: '',
              role: _selectedRole ?? 'Customer',
              imageUrl: _imageUrl ?? '');

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update(updatedUserModel.toDocument());

          // Show a success message or navigate to another page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User details updated successfully!')),
          );
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } catch (e) {
        // Handle errors
        showErrorAuthBottomSheet(context);
      }
    }
  }

  String role = '';
  User user = FirebaseAuth.instance.currentUser!;
  void _fetchDataFromFirestore() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    setState(() {
      role = querySnapshot.docs[0]['role'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: AppColors.bgColor,
            ),
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
                        Space.yf(1.5),
                        // Image Picker
                        GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.lightGrey,
                              backgroundImage: _imageFile != null
                                  ? FileImage(File(_imageFile!
                                      .path)) // Display the picked image
                                  : null, // Set to null if using network image below
                              child: _imageFile == null
                                  ? (_imageUrl != null && _imageUrl!.isNotEmpty
                                      ? ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: _imageUrl!,
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                            placeholder: (context, url) =>
                                                Center(
                                              child:
                                                  CupertinoActivityIndicator(), // Show while loading
                                            ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.broken_image,
                                              size: 40,
                                              color: Colors
                                                  .grey, // Show if loading fails
                                            ),
                                          ),
                                        )
                                      : Icon(Icons.camera_alt,
                                          size:
                                              40)) // Show if no image is available
                                  : null,
                            )),
                        Space.yf(1.5),
                        customTextFormField(
                            label: "Name*",
                            svgUrl: AppAssets.username,
                            controller: _nameController,
                            validator: _validators.validateFirstName),
                        if (idX == '')
                          Column(
                            children: [
                              Space.yf(1.3),
                              customTextFormField(
                                  label: "Email*",
                                  svgUrl: AppAssets.email,
                                  controller: _emailController,
                                  validator: _validators.validateEmail),
                              Space.yf(1.3),
                            ],
                          ),
                        customTextFormField(
                            label: "Phone Number*",
                            svgUrl: AppAssets.phone,
                            controller: _phoneController,
                            validator: _validators.validatePhoneNumber),
                        if (idX == '')
                          Column(
                            children: [
                              Space.yf(1.3),
                              customTextFormField(
                                  label: "Password*",
                                  svgUrl: AppAssets.password,
                                  controller: _passwordController,
                                  validator: (value) {
                                    if (idX == '') {
                                      _validators.validatePassword;
                                    }
                                    return null;
                                  }),
                              Space.yf(1.3),
                              customTextFormField(
                                  label: "Confirm Password*",
                                  svgUrl: AppAssets.password,
                                  controller: _confirmPasswordController,
                                  validator: (value) {
                                    if (idX == '') {
                                      _validators.validateConfirmPassword(
                                        _passwordController.text,
                                        value,
                                      );
                                    }
                                    return null;
                                  }),
                            ],
                          ),
                        Space.yf(1.5),
                        // Role Dropdown
                        if (user.email == 'iakena420@gmail.com' ||
                            role == 'Administrator' ||
                            role == 'Manager' ||
                            role == 'Head Of Department')
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedRole = newValue;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Select Role*',
                              prefixIcon: Icon(Icons.account_circle),
                              filled: true,
                            ),
                            items: _roles.map((String role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a role';
                              }
                              return null;
                            },
                          ),
                        Space.yf(1.5),
                        _isEditing
                            ? customElevatedButton(
                                onTap: _updateUserDetails,
                                text: "UPDATE",
                                heightFraction: 20,
                                width: double.infinity,
                                color: AppColors.commonAmber,
                              )
                            : customElevatedButton(
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
          );
  }

  void show() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: CupertinoActivityIndicator(),
          );
        });
  }
}
