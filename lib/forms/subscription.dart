import 'package:flutter/material.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';

import 'package:instawash/models/repo.dart';
import 'package:instawash/models/subscription.dart';
import 'package:uuid/uuid.dart';


class SubscriptionForm extends StatefulWidget {
  final String serviceId;
  const SubscriptionForm({super.key, required this.serviceId});

  @override
  SubscriptionFormState createState() => SubscriptionFormState();
}

class SubscriptionFormState extends State<SubscriptionForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();

  Future<void> _uploadData() async {
    if (_formKey.currentState!.validate()) {
      Subscription subscription = Subscription(
          id: const Uuid().v4(),
          serviceId: widget.serviceId,
          category: _categoryController.text,
          discount: double.parse(_discountController.text),
          subServiceId: '',
          moreServiceId: '',
          numberOfDay: int.parse(_daysController.text));

      Repo().addSubscription(subscription);
      print('Subscription data uploaded to Firestore');
      Navigator.pop(context);
    }
  }

  bool _isConnected = true; // Default to true, assuming there's a connection

  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _checkInternetConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Subscription Form'),
              backgroundColor: Colors.blue[900], // Dark blue app bar
              iconTheme: const IconThemeData(
                  color: Colors.white), // White app bar icon
            ),
            body: Container(
              color: Colors.purple, // Purple background
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _categoryController,
                        style:
                            const TextStyle(color: Colors.white), // White text
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _daysController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: false),
                        style:
                            const TextStyle(color: Colors.white), // White text
                        decoration: const InputDecoration(
                          labelText: 'Number of Days',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of days';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _discountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style:
                            const TextStyle(color: Colors.white), // White text
                        decoration: const InputDecoration(
                          labelText: 'Discount',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the discount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _uploadData,
                        child: const Text('Upload Subscription'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }
}
