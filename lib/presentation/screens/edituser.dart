import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instawash/configs/app_dimensions.dart';
import 'package:instawash/configs/space.dart';
import 'package:instawash/presentation/widgets.dart';
import 'package:instawash/core/core.dart';

class EditUserPage extends StatefulWidget {
  final Map<String, dynamic> existingUser;

  const EditUserPage({
    super.key,
    required this.existingUser,
  });

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the existing user's data
    _nameController.text = widget.existingUser['fullName'] ?? '';
    _phoneController.text = widget.existingUser['phoneNumber'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Function to update user data in Firebase Firestore
  Future<void> _updateUser() async {
    final Map<String, dynamic> updatedUser = {
      'fullName': _nameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.existingUser['id']) // Use the user's document ID
          .update(updatedUser);

      // Show a success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User updated successfully.")),
      );
      Navigator.pop(context);
    } catch (e, stackTrace) {
      print("Error updating user: $e");
      print(stackTrace); // Log stack trace for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to update user. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
                  customTextFormField(
                    label: "Name*",
                    svgUrl: AppAssets.username,
                    controller: _nameController,
                    validator: (value) => value?.isEmpty ?? true
                        ? "Please enter your name"
                        : null,
                  ),
                  Space.yf(1.3),
                  customTextFormField(
                    label: "Phone Number*",
                    svgUrl: AppAssets.phone,
                    controller: _phoneController,
                    validator: (value) => value?.isEmpty ?? true
                        ? "Please enter your phone number"
                        : null,
                  ),
                  Space.yf(1.5),
                  customElevatedButton(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        _updateUser();
                      }
                    },
                    text: "Save Changes",
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
}
