import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';

import 'package:instawash/models/repo.dart';
import 'package:instawash/models/subscription_offer.dart';
import 'package:uuid/uuid.dart';

class SubscriptionOffersForm extends StatefulWidget {
  final String serviceId;
  final String subId;
  const SubscriptionOffersForm(
      {super.key, required this.serviceId, required this.subId});

  @override
  SubscriptionOffersFormState createState() => SubscriptionOffersFormState();
}

class SubscriptionOffersFormState extends State<SubscriptionOffersForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _uploadData() async {
    if (_formKey.currentState!.validate()) {
      SubscriptionOffer subscriptionOffer = SubscriptionOffer(
        id: const Uuid().v4(),
        name: _nameController.text,
        serviceId: widget.serviceId,
        subId: widget.subId,
      );

      Repo().addSubscriptionOffer(subscriptionOffer);

      if (kDebugMode) {
        print('SubscriptionOffer data uploaded to Firestore');
      }
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
              title: const Text('SubscriptionOffers Form'),
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
                      TextFormField(
                        controller: _nameController,
                        style:
                            const TextStyle(color: Colors.white), // White text
                        decoration: const InputDecoration(
                          labelText: 'Offer Name',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the offer name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _uploadData,
                        child: const Text('Upload SubscriptionOffer'),
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
    _nameController.dispose();
    super.dispose();
  }
}
