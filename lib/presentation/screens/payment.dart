import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instawash/models/booking.dart';
import 'package:instawash/models/more_service.dart';
import 'package:instawash/models/payment.dart';
import 'package:instawash/models/repo.dart';
import 'package:instawash/models/selected_more_service.dart';
import 'package:instawash/models/sub_service.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:instawash/ordersuccess.dart';
import 'package:uuid/uuid.dart';

class ServicePayment extends StatefulWidget {
  final String serviceId;

  final SubService? subservice;
  final List<MoreService>? selectedMoreServices;
  final double? total;

  final String? uid;
  final String? pickUpAddress;
  final DateTime? date;
  final TimeOfDay? time;

  final double? pickUpLongitude;
  final double? pickUpLatitude;
  const ServicePayment(
      {super.key,
      required this.serviceId,
      this.pickUpAddress,
      this.pickUpLatitude,
      this.pickUpLongitude,
      this.selectedMoreServices,
      this.subservice,
      this.total,
      this.uid,
      this.date,
      this.time});
  @override
  _ServicePaymentState createState() => _ServicePaymentState();
}

class _ServicePaymentState extends State<ServicePayment> {
  final TextEditingController phoneController =
      TextEditingController(text: '256');

  void _submitPayment() async {
    int enteredPhone = int.parse(phoneController.text);

    final String ref = Uuid().v4();
    final PaymentRequest paymentRequest = PaymentRequest(
      username: "9b5393a623a5de8a",
      password: "ad47e48ccf4697e8",
      action: "mmdeposit",
      amount: calculateTotalPrice().toInt(),
      currency: "UGX",
      phone: enteredPhone.toString(),
      reference: ref,
      reason: "Payment for service",
    );

    if (enteredPhone.toString().length == 12) {
      await payWithMobileMoney(
          paymentRequest, context, enteredPhone.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid phone number')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Payment Details')),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please confirm your Mobile Money number:'),
                const SizedBox(height: 15),
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
                    if (value.length <= 12 && value.startsWith('256')) {
                      phoneController.text = value;
                    } else if (!value.startsWith('256')) {
                      phoneController.text = '256';
                    }
                    phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: phoneController.text.length),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.red)),
                    ),
                    ElevatedButton.icon(
                      onPressed: _submitPayment,
                      icon: const Icon(Icons.send),
                      label: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double calculateTotalPrice() {
    double total = widget.subservice!.price;

    for (MoreService moreService in widget.selectedMoreServices!) {
      total += moreService.price;
    }

    return total;
  }

  Future<void> payWithMobileMoney(
      PaymentRequest request, BuildContext context, String enteredPhone) async {
    const apiUrl =
        'https://www.easypay.co.ug/api/'; // Replace with your API URL

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Processing Payment...',
            style: TextStyle(color: Colors.black),
          ),
          content: SizedBox(
            height: 100,
            child: Column(
              children: [
                Text('Phone Number: $enteredPhone'),
                Text('Dont close app unless Payment is complete!'),
                CupertinoActivityIndicator(),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Convert PaymentRequest object to JSON
      final jsonData = jsonEncode(request.toJson());

      // Make POST request to API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          "Access-Control_Allow_Origin": "*",
          "Access-Control-Allow-Headers": "Access-Control-Allow-Origin, Accept"
        },
        body: jsonData,
      );

      // Check if request was successful
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == 1) {
          final String txRef = "ref_${Random().nextInt(100000)}";
          // DateTime createdAt = DateTime.now(); // Current date and time
          // int numberOfDays = 7; // The number of days to add

// Calculate the end date by adding 7 days to the createdAt date
          // DateTime endDate = createdAt.add(Duration(days: numberOfDays));
          // double newPrice =
          //     widget.total! - (widget.total!);
          final user = FirebaseAuth.instance.currentUser!;

          print('Payment successful');
          print('Response: ${response.body}');
          Booking booking = Booking(
            id: txRef,
            userId: user.uid,
            subscriptionId: '',
            subscriptionName: '',
            serviceName: widget.serviceId,
            subServiceId: widget.subservice!.name,
            moreServiceId: '',
            price: widget.total!,
            status: 'Pending',
            date: widget.date!,
            additionalInfo: '',
            location: widget.pickUpAddress!,
            durationInMinutes: 0,
            startDate: DateTime.now(),
            completeDate: DateTime.now(),
            comment: '',
            latitude: widget.pickUpLatitude!,
            longitude: widget.pickUpLongitude!,
            savedTime: DateTime.now(),
            time: widget.time!,
            type: 'Instant',
            dispatchId: '',
            customerCare: '',
          );

          Repo().addBooking(booking).catchError((onError) {
            debugPrint(onError.toString());
          });

          for (MoreService moreService in widget.selectedMoreServices!) {
            SelectedMoreService selectedMoreService = SelectedMoreService(
              id: Uuid().v4(),
              serviceId: moreService.serviceId,
              subServiceId: moreService.subServiceId,
              userId: user.uid,
              bookingId: txRef,
              name: moreService.name,
              description: moreService.description,
              price: moreService.price,
              imageUrl: moreService.imageUrl,
              moreServiceId: moreService.id,
            );
            Repo().addSelectedMoreService(selectedMoreService);
          }
          Get.offAll(() => OrderSuccessfulPage());
        } else {
          print('Payment failed');
          print('Response: ${response.body}');
          Navigator.pop(context); // Close the AlertDialog
          // Handle payment failure
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Payment Failed'),
                content: Text(responseBody['errormsg']),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print('Error occurred: $e');
      Navigator.pop(context); // Close the AlertDialog
      // Handle any errors that occurred during the API call
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while processing payment.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  String pay() {
    if (calculateTotalPrice() == 0) {
      return 'Request for Quotation';
    } else {
      return 'Pay UGX ${calculateTotalPrice()} ';
    }
  }
}

// Dummy function placeholders (replace with actual implementations)
 