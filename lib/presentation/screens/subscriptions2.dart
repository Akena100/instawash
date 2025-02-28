import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/forms/subscription_offers.dart';
import 'package:instawash/models/booking.dart';
import 'package:instawash/models/more_service.dart';
import 'package:instawash/models/payment.dart';
import 'package:instawash/models/repo.dart';
import 'package:instawash/models/selected_more_service.dart';

import 'package:instawash/models/sub_service.dart';
import 'package:instawash/models/subscription.dart';
import 'package:instawash/models/subscription_offer.dart';
import 'package:instawash/models/user_subscription.dart';
import 'package:instawash/ordersuccess.dart';
import 'package:instawash/presentation/screens/sub_service.dart';
import 'package:uuid/uuid.dart';
import '../../forms/subscription.dart';

class SubscriptionPage2 extends StatefulWidget {
  final String serviceId;

  final SubService? subservice;
  final List<MoreService>? selectedMoreServices;
  final double? total;
  final DateTime? date;
  final TimeOfDay? time;
  final String? uid;
  final String? pickUpAddress;
  final Subscription? subscription;
  final double? pickUpLongitude;
  final double? pickUpLatitude;
  const SubscriptionPage2(
      {super.key,
      required this.serviceId,
      this.date,
      this.pickUpAddress,
      this.pickUpLatitude,
      this.pickUpLongitude,
      this.selectedMoreServices,
      this.subservice,
      this.subscription,
      this.time,
      this.total,
      this.uid});
  @override
  SubscriptionPageState createState() => SubscriptionPageState();
}

class SubscriptionPageState extends State<SubscriptionPage2> {
  bool _isConnected = true; // Default to true, assuming there's a connection
  TextEditingController controller = TextEditingController();

  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
  }

  void _onPressed(Subscription subscription) async {
    final user = FirebaseAuth.instance.currentUser!;
    final String txRef = "ref_${Random().nextInt(100000)}";

    if (kDebugMode) {
      print(user.email);
    }
    if (_isConnected == false) {
      debugPrint('ssddhhdhdhdhhdhdhdhdhdhdh');
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => NoInternetConnectionPage()));
    } else {
      if (calculateTotalPrice() != 0) {
        payNumber(context, subscription);
      } else {
        saving(context);
        debugPrint('price is empty');
        DateTime createdAt = DateTime.now(); // Current date and time
        int numberOfDays = 7; // The number of days to add

        // Calculate the end date by adding 7 days to the createdAt date
        DateTime endDate = createdAt.add(Duration(days: numberOfDays));
        final user = FirebaseAuth.instance.currentUser!;

        Booking booking = Booking(
          id: txRef,
          userId: user.uid,
          subscriptionId: subscription.id,
          subscriptionName: subscription.category,
          serviceName: widget.serviceId,
          subServiceId: widget.subservice!.name,
          moreServiceId: '',
          price: 0.0,
          status: 'Pending',
          date: widget.date!,
          additionalInfo: '',
          location: widget.pickUpAddress!,
          durationInMinutes: 0,
          startDate: DateTime.now(),
          completeDate: DateTime.now(),
          comment: controller.text,
          latitude: widget.pickUpLatitude!,
          longitude: widget.pickUpLongitude!,
          savedTime: DateTime.now(),
          time: widget.time!,
          type: 'Quotation',
          dispatchId: '',
          customerCare: '',
        );

        UserSubscription userSubscription = UserSubscription(
            id: Uuid().v4(),
            userId: user.uid,
            serviceId: widget.serviceId,
            subServiceId: widget.subservice!.id,
            moreServiceId: '',
            category: subscription.category,
            price: 0,
            discount: subscription.discount,
            createdAt: createdAt,
            endDate: endDate);

        Repo().addBooking(booking).catchError((onError) {
          debugPrint(onError.toString());
        });
        Repo().addUserSubscription(userSubscription).catchError((onError) {
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
      }
    }
  }

  saving(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: CupertinoActivityIndicator(),
          );
        });
  }

  void payNumber(BuildContext context, Subscription subscription) async {
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
                const Text('Please confirm your Mobile Money number:'),
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
              onPressed: () async {
                final enteredPhone = phoneController.text;
                final String ref = "ref_${Random().nextInt(100000)}";
                final PaymentRequest paymentRequest = PaymentRequest(
                  username: "9b5393a623a5de8a",
                  password: "ad47e48ccf4697e8",
                  action: "mmdeposit",
                  amount: calculateTotalPrice().toInt(),
                  currency: "UGX",
                  phone: enteredPhone,
                  reference: ref,
                  reason: "Payment for service",
                );
                if (RegExp(r'^256\d{9}$').hasMatch(enteredPhone)) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Payment initiated for $enteredPhone')),
                  );

                  await payWithMobileMoney(
                      paymentRequest, context, enteredPhone, subscription);
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

  double calculateTotalPrice() {
    double total = widget.subservice!.price;

    for (MoreService moreService in widget.selectedMoreServices!) {
      total += moreService.price;
    }

    return total;
  }

  Future<void> payWithMobileMoney(PaymentRequest request, BuildContext context,
      String enteredPhone, Subscription subscription) async {
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
            height: 65,
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
          DateTime createdAt = DateTime.now(); // Current date and time
          int numberOfDays = 7; // The number of days to add

// Calculate the end date by adding 7 days to the createdAt date
          DateTime endDate = createdAt.add(Duration(days: numberOfDays));
          double newPrice =
              widget.total! - (widget.total! * subscription.discount / 100);
          final user = FirebaseAuth.instance.currentUser!;

          print('Payment successful');
          print('Response: ${response.body}');
          Booking booking = Booking(
            id: txRef,
            userId: user.uid,
            subscriptionId: subscription.id,
            subscriptionName: subscription.category,
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
            comment: controller.text,
            latitude: widget.pickUpLatitude!,
            longitude: widget.pickUpLongitude!,
            savedTime: DateTime.now(),
            time: widget.time!,
            type: 'Instant',
            dispatchId: '',
            customerCare: '',
          );

          UserSubscription userSubscription = UserSubscription(
              id: Uuid().v4(),
              userId: user.uid,
              serviceId: widget.serviceId,
              subServiceId: widget.subservice!.id,
              moreServiceId: '',
              category: subscription.category,
              price: newPrice,
              discount: subscription.discount,
              createdAt: createdAt,
              endDate: endDate);

          Repo().addBooking(booking).catchError((onError) {
            debugPrint(onError.toString());
          });
          Repo().addUserSubscription(userSubscription).catchError((onError) {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkInternetConnection();
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'Subscriptions',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.secondaryColor,
            ),
            body: Container(
              color: AppColors.bgColor,
              padding: const EdgeInsets.all(16),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('subscriptions')
                    .where('serviceId', isEqualTo: widget.serviceId)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot subscriptionDoc =
                          snapshot.data!.docs[index];
                      Subscription subscription = Subscription(
                        id: subscriptionDoc.id,
                        serviceId: subscriptionDoc['serviceId'],
                        category: subscriptionDoc['category'],
                        discount: subscriptionDoc['discount'].toDouble(),
                        subServiceId: '',
                        moreServiceId: '',
                        numberOfDay: subscriptionDoc['numberOfDay'].toInt(),
                      );

                      return Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star_border_outlined,
                              color: Colors.orangeAccent,
                              size: 40,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              subscription.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              ' ${subscription.discount.toString()}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                                onPressed: () {
                                  if (widget.subscription != null) {
                                    Get.to(() => SubServicesPage(
                                          serviceId: widget.serviceId,
                                          subscription: subscription,
                                        ));
                                  } else {
                                    _onPressed(subscription);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(250, 50)),
                                child: const Text("Book Now")),
                            const Divider(
                              color: Colors.white,
                            ),
                            SubscriptionOffersList(
                                subscriptionId: subscription.id,
                                serviceId: widget.serviceId),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Visibility(
                                  visible: x(),
                                  child: ElevatedButton(
                                      onPressed: () =>
                                          Get.to(() => SubscriptionOffersForm(
                                                serviceId: widget.serviceId,
                                                subId: subscription.id,
                                              )),
                                      child: const Text('Add +')),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            floatingActionButton: Visibility(
              visible: x(),
              child: FloatingActionButton(
                onPressed: () {
                  Get.to(() => SubscriptionForm(
                        serviceId: widget.serviceId,
                      ));
                  // Implement logic to add new Subscription
                },
                backgroundColor: Colors.blue[900],
                child: Icon(Icons.add, color: Colors.white),
              ),
            ));
  }

  bool x() {
    final u = FirebaseAuth.instance.currentUser;
    if (u != null && u.email == 'iakena420@gmail.com' ||
        u!.email == 'samomwony909@gmail.com') {
      return true;
    }
    return false;
  }
}

class SubscriptionOffersList extends StatelessWidget {
  final String subscriptionId;
  final String serviceId;

  const SubscriptionOffersList(
      {super.key, required this.subscriptionId, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('subscriptionOffers')
          .where('serviceId', isEqualTo: serviceId)
          .where('subId', isEqualTo: subscriptionId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data?.docs.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot offerDoc = snapshot.data!.docs[index];
            SubscriptionOffer offer = SubscriptionOffer(
              id: offerDoc.id,
              name: offerDoc['name'],
              serviceId: offerDoc['serviceId'],
              subId: offerDoc['subId'],
            );

            return ListTile(
              leading: const Icon(Icons.check, color: Colors.green),
              title: Text(
                offer.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                // Add your logic for handling subscription offer selection
              },
            );
          },
        );
      },
    );
  }
}
