import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/drawer.dart';
import 'package:instawash/models/booking.dart';
import 'package:instawash/models/models.dart';
import 'package:instawash/models/notifications.dart';
import 'package:instawash/models/repo.dart';
import 'package:instawash/presentation/screens/checkout%20copy.dart';
import 'package:instawash/server_key.dart';
import 'package:search_page/search_page.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});
  @override
  PackagesScreenState createState() => PackagesScreenState();
}

class PackagesScreenState extends State<PackagesScreen> {
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

  Future<String?> getUserToken(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc['city']; // Ensure you have a 'city' field
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user token from Firestore: $e');
      return null;
    }
  }

  // Function to send push notification using HTTP v1 API
  Future<void> sendPushNotification(
      String token, String message, String id) async {
    try {
      final t = GetServerKey();
      final accessToken = await t.servertoken();
      debugPrint('Access Token: $accessToken');
      debugPrint('Device Token: $token');

      var url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/insta-wash01/messages:send');
      debugPrint('FCM URL: $url');

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      var body = json.encode({
        'message': {
          'token': token,
          'notification': {
            'title': 'Intawash Team Service',
            'body': message,
          },
          'data': {'extra_data_key': 'extra_data_value'}
        }
      });

      var response = await http.post(url, headers: headers, body: body);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('Notification sent successfully');

        Notifications notification = Notifications(
          id: Uuid().v4(),
          userId: id,
          message: message,
          title: 'Intawash Service Team',
          notificationDate: DateTime.now(),
        );
        Repo().addNotification(notification);
      } else {
        debugPrint(
            'Failed to send notification. Status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to send notification. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('Error sending push notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending notification. Check logs.')),
      );
    }
  }

  // Function to handle sending notification
  void _sendNotification(String id) async {
    String recipientUserId = id;
    String message = 'You have been Dispatched';
    if (message.isNotEmpty) {
      String? token = await getUserToken(recipientUserId);
      if (token != null) {
        await sendPushNotification(token, message, id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User token not found.')),
        );
      }
    }
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
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: AppColors.secondaryColor,
              title: const Text(
                'INSTA WASH MOBILE',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            drawer: const CustomDrawer(),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Bookings".toUpperCase(),
                            style: const TextStyle(
                                fontSize: 25, color: Colors.white),
                          ),
                          // if (FirebaseAuth.instance.currentUser!.email ==
                          //     'iakena420@gmail.com')
                          //   ElevatedButton(
                          //       onPressed: () {}, child: const Text('New +'))
                        ]),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('bookings')
                            .where('userId', isEqualTo: user.uid)
                            .orderBy('savedTime', descending: true)
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
                                        trailing: Visibility(
                                          visible: x(),
                                          child: PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'dispatch') {
                                                showSearch(
                                                  context: context,
                                                  delegate: SearchPage(
                                                    showItemsOnEmpty: true,
                                                    barTheme: ThemeData(
                                                      textTheme:
                                                          const TextTheme(
                                                        bodyLarge: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    onQueryUpdate: print,
                                                    items: itemsTemp,
                                                    searchLabel:
                                                        'Search service',
                                                    suggestion: const Center(
                                                      child: Text(
                                                          'Filter drivers by name, category or description'),
                                                    ),
                                                    failure: const Center(
                                                      child: Text(
                                                          'No item found :('),
                                                    ),
                                                    filter: (product) => [
                                                      product['fullName'],
                                                    ],
                                                    builder: (product) =>
                                                        ListTile(
                                                      leading: Image.network(
                                                        '${product['imageUrl']}',
                                                        width: 60,
                                                        height: 60,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      title: Text(
                                                          product['fullName']),
                                                      onTap: () async {
                                                        try {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                      AlertDialog(
                                                                        content:
                                                                            CupertinoActivityIndicator(),
                                                                      ));
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'bookings')
                                                              .doc(booking.id)
                                                              .update({
                                                            'dispatchId':
                                                                product['id'],
                                                            'status':
                                                                'Confirmed',
                                                          });

                                                          if (booking.dispatchId
                                                              .isNotEmpty) {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(booking
                                                                    .dispatchId)
                                                                .update({
                                                              'address':
                                                                  'Active',
                                                            });
                                                          }
                                                          final user = UserModel
                                                              .fromSnapshot(
                                                                  product);
                                                          _sendNotification(
                                                              user.id);

                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                        } catch (e) {
                                                          print(
                                                              "Error updating Firestore: $e");
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                );
                                              } else if (value == 'cancel') {
                                                FirebaseFirestore.instance
                                                    .collection('bookings')
                                                    .doc(booking.id)
                                                    .update({
                                                  'status': 'Cancelled'
                                                });
                                                setState(() {});
                                              } else if (value == 'complete') {
                                                FirebaseFirestore.instance
                                                    .collection('bookings')
                                                    .doc(booking.id)
                                                    .update(
                                                        {'status': 'Complete'});
                                                setState(() {});
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'dispatch',
                                                child: Text('Dispatch'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'cancel',
                                                child: Text('Cancel'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'complete',
                                                child: Text('Complete'),
                                              ),
                                            ],
                                          ),
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

                                      // Text(
                                      //   booking.time,
                                      //   style: const TextStyle(
                                      //       color: Colors.white),
                                      // ),
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
                                        child: const Text('View Details'),
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
    if (FirebaseAuth.instance.currentUser!.email == 'iakena420@gmail.com' ||
        FirebaseAuth.instance.currentUser!.email == 'uginstawash@gmail.com') {
      return true;
    }
    return false;
  }
}
