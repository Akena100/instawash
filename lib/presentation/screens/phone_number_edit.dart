import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpdatePhoneNumberPage extends StatefulWidget {
  const UpdatePhoneNumberPage({super.key});

  @override
  UpdatePhoneNumberPageState createState() => UpdatePhoneNumberPageState();
}

class UpdatePhoneNumberPageState extends State<UpdatePhoneNumberPage> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _updatePhoneNumber() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number cannot be empty")),
      );
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatically verify and update phone number
          await _auth.currentUser?.updatePhoneNumber(credential);
          Future<void> updatePhoneNumber(BuildContext context) async {
            await Future.delayed(Duration(seconds: 2)); // Simulating async work

            if (!context.mounted)
              return; // Ensure the widget is still mounted before using context

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Phone number updated successfully")),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${e.message}")),
          );
        },
        codeSent: (String verificationId, int? resendToken) async {
          // Prompt the user to input the verification code
          String? smsCode = await _showCodeInputDialog();

          if (smsCode != null && smsCode.isNotEmpty) {
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );

            // Update phone number
            await _auth.currentUser?.updatePhoneNumber(credential);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Phone number updated successfully")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Verification canceled")),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Code auto-retrieval timeout")),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<String?> _showCodeInputDialog() async {
    final TextEditingController codeController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Verification Code"),
          content: TextField(
            controller: codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Verification Code",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, codeController.text.trim()),
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Phone Number"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updatePhoneNumber,
              child: const Text("Update Phone Number"),
            ),
          ],
        ),
      ),
    );
  }
}
