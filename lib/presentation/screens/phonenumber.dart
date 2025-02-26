import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentFormPage extends StatelessWidget {
  const PaymentFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Page')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _showPaymentDialog(context),
          icon: const Icon(Icons.payment),
          label: const Text('Make a Payment'),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    // Default phone number
    const defaultPhoneNumber = '256'; // Country code
    final phoneController = TextEditingController(text: defaultPhoneNumber);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: const Text('Enter Payment Details'),
          content: SizedBox(
            width: 350, // Set the width of the dialog
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please confirm your phone number:'),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_android),
                    labelText: 'Phone Number',
                    hintText: '256XXXXXXXXX',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLength: 12,
                  onChanged: (value) {
                    // Only allow input starting with '256' and up to 12 digits
                    if (value.length <= 12 && value.startsWith('256')) {
                      // Keep the value as is if it starts with '256' and is no longer than 12 digits
                      phoneController.text = value;
                    } else if (!value.startsWith('256')) {
                      // If the value does not start with '256', reset the input to the default value
                      phoneController.text = '256';
                    }
                    phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: phoneController.text.length),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final enteredPhone = phoneController.text;
                if (RegExp(r'^256\d{9}$').hasMatch(enteredPhone)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Payment initiated for $enteredPhone')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid phone number')),
                  );
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
