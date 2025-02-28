import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/models/booking.dart';
import 'package:instawash/models/notifications.dart';
import 'package:instawash/models/repo.dart';

import 'package:instawash/server_key.dart';
import 'package:slider_button/slider_button.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class CompleteButton extends StatefulWidget {
  final Booking booking;

  const CompleteButton({super.key, required this.booking});

  @override
  JourneyButtonState createState() => JourneyButtonState();
}

class JourneyButtonState extends State<CompleteButton> {
  final bool _buttonVisible = true;
  // Function to get the user's token from Firestore
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
  Future<void> sendPushNotification(String token, String message) async {
    try {
      final t = GetServerKey();
      final accessToken = await t.servertoken(); // Await the result
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
            'title': 'Intawash Team Services',
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
          userId: widget.booking.userId,
          message: message,
          title: 'Alert!',
          notificationDate: DateTime.now(),
        );
        Repo().addNotification(notification);
      } else {
        debugPrint(
            'Failed to send notification. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending push notification: $e');
    }
  }

  // Function to handle sending notification
  void _sendNotification() async {
    String recipientUserId = widget.booking.userId;
    String message = 'Customer cancelled!';
    if (message.isNotEmpty) {
      String? token = await getUserToken(recipientUserId);
      if (token != null) {
        await sendPushNotification(token, message);
      } else {
        debugPrint('User token not found.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buttonVisible
        ? SliderButton(
            action: () async {
              _sendNotification();
              FirebaseFirestore.instance
                  .collection('bookings')
                  .doc(widget.booking.id)
                  .update({'status': 'Complete'});
              Navigator.pop(context);
              showDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: Text('Job Completed'),
                      content: Text('Well Done!'),
                      actions: [
                        ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Okay'))
                      ],
                    );
                  });
              return true;
            },
            label: Text(
              "Complete the Job!",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            icon: Center(
              child: Icon(
                Icons.done,
                color: Colors.green,
                size: 40.0,
              ),
            ),
            width: 250,
            radius: 10,
            buttonColor: AppColors.secondaryColor,
            backgroundColor: Colors.grey.shade800,
            highlightedColor: Colors.green,
            boxShadow: BoxShadow(color: Colors.green, blurRadius: 10),
            baseColor: AppColors.secondaryColor,
          )
        : Container(); // Placeholder to prevent UI shift
  }
}
