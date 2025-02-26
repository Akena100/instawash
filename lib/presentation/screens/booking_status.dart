import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/core/constants/colors.dart';

import 'package:instawash/models/booking.dart';
import 'package:instawash/presentation/screens/checkout%20copy.dart';

class BookingStatus extends StatefulWidget {
  final String title;
  const BookingStatus({super.key, required this.title});
  @override
  DriverBookingState createState() => DriverBookingState();
}

class DriverBookingState extends State<BookingStatus> {
  bool _isConnected = true; // Default to true, assuming there's a connection
  final User user = FirebaseAuth.instance.currentUser!;
  List itemsTemp = [];
  int itemLength = 0;
  String text = '';

  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
  }

  void _fetchDataFromFirestore() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Driver')
        .get();

    setState(() {
      itemsTemp = querySnapshot.docs
          .map((DocumentSnapshot document) =>
              document.data() as Map<String, dynamic>)
          .toList();
      itemLength = itemsTemp.length;
    });
  }

  @override
  void initState() {
    _checkInternetConnection();
    _fetchDataFromFirestore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : Scaffold(
            backgroundColor: AppColors.bgColor,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${widget.title} Bookings".toUpperCase(),
                            style: const TextStyle(
                                fontSize: 25, color: Colors.white),
                          ),
                        ]),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('bookings')
                            .where('status', isEqualTo: widget.title)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<Booking> bookings = snapshot.data!.docs
                                .map((doc) => Booking.fromSnapshot(doc))
                                .toList();

                            return ListView.builder(
                              itemCount: bookings.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                Booking booking = bookings[index];
                                final List<String> statusList = [
                                  'Complete',
                                  'Comfirmed'
                                      'Pending',
                                  'Cancelled'
                                      'On Route',
                                ];

                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryColor,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Text(
                                          booking.subServiceId,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const Divider(),
                                      const SizedBox(height: 10),
                                      ListTile(
                                        title: Text(
                                          'BID: Copy Booking ID',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        trailing: IconButton(
                                            onPressed: () {
                                              text = booking.id;
                                              copy(text);
                                            },
                                            icon: Icon(Icons.copy)),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          _buildStatusIcon(statusList
                                              .indexOf(booking.status)),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Status: ${booking.status}',
                                            style: const TextStyle(
                                                color: Colors.red),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      if (booking.dispatchId.isNotEmpty)
                                        ListTile(
                                          title: Text(
                                            'DID: Copy Dispatch ID',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          trailing: IconButton(
                                              onPressed: () {
                                                text = booking.dispatchId;
                                                copy(text);
                                              },
                                              icon: Icon(Icons.copy)),
                                        ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          Text(
                                            '${booking.date.hour} : ${booking.date.minute}',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      const Divider(),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          minimumSize: WidgetStateProperty.all(
                                              const Size(double.infinity,
                                                  50)), // Adjust the width and height as needed
                                        ),
                                        onPressed: () async {
                                          you(context);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CheckoutPage2(
                                                          booking: booking)));
                                          // Add functionality for the View button
                                        },
                                        child: const Text('Details'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                      )),
                ],
              ),
            ),
          );
  }

  Widget _buildStatusIcon(int statusIndex) {
    IconData iconData;
    Color iconColor;

    switch (statusIndex) {
      case 0: // Complete
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 1: // Confirmed
        iconData = Icons.check;
        iconColor = Colors.white;
        break;
      case 2: // Pending
        iconData = Icons.timer;
        iconColor = Colors.orange;
        break;
      case 3: // Canceled
        iconData = Icons.cancel;
        iconColor = Colors.red; // Change to the appropriate color
      case 4: // Route
        iconData = Icons.fire_truck_rounded;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.error;
        iconColor = Colors.grey;
    }

    return Icon(
      iconData,
      color: iconColor,
    );
  }

  void you(BuildContext context) {}

  void copy(String copy) {
    Clipboard.setData(ClipboardData(text: copy));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Copied to Clipboard"),
    ));
  }

  x() {
    if (FirebaseAuth.instance.currentUser!.email == 'iakena420@gmail.com') {
      return true;
    }
    return false;
  }
}
