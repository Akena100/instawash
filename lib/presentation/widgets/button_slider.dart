import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/models/booking.dart';
import 'package:instawash/models/notifications.dart';
import 'package:instawash/models/repo.dart';
import 'package:instawash/presentation/widgets/track.dart';
import 'package:instawash/server_key.dart';
import 'package:slider_button/slider_button.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class JourneyButton extends StatefulWidget {
  final Booking booking;

  const JourneyButton({super.key, required this.booking});

  @override
  JourneyButtonState createState() => JourneyButtonState();
}

class JourneyButtonState extends State<JourneyButton> {
  bool _buttonVisible = true;

  Future<String?> getUserToken() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.booking.userId)
          .get();
      if (userDoc.exists) {
        debugPrint('User document: ${userDoc.data()}');
        return userDoc['city'];
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user token from Firestore: $e');
      return null;
    }
  }

  Future<void> sendPushNotification(String token, String message) async {
    try {
      final t = GetServerKey();
      final accessToken = await t.servertoken();

      if (token.isEmpty || accessToken.isEmpty) {
        debugPrint('Error: Missing token or access token');
        return;
      }

      var url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/insta-wash01/messages:send');
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
          userId: widget.booking.userId,
          message: message,
          title: 'Intawash Service Team',
          notificationDate: DateTime.now(),
        );
        Repo().addNotification(notification);
      } else {
        debugPrint(
            'Failed to send notification. Status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send notification.')),
        );
      }
    } catch (e) {
      debugPrint('Error sending push notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending notification. Check logs.')),
      );
    }
  }

  void _sendNotification() async {
    String message = 'We are on our way!';
    if (message.isNotEmpty) {
      String? token = await getUserToken();
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
              setState(() => _buttonVisible = false);

              _sendNotification(); // Send notification before navigation
              await Get.to(() => TrackingScreen(booking: widget.booking));

              try {
                DocumentReference docRef = FirebaseFirestore.instance
                    .collection('bookings')
                    .doc(widget.booking.id);

                DocumentSnapshot docSnap = await docRef.get();
                if (docSnap.exists) {
                  await docRef.update({'status': 'On Route'});
                  debugPrint("Booking status updated successfully.");
                } else {
                  debugPrint("Error: Booking document does not exist.");
                }
              } catch (e) {
                debugPrint("Error updating booking status: $e");
              }

              setState(() => _buttonVisible = true);
              return true;
            },
            label: Text(
              "Go to Customer!",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            icon: Center(
              child: Icon(
                Icons.fire_truck,
                color: Colors.white,
                size: 40.0,
              ),
            ),
            width: 250,
            radius: 10,
            buttonColor: AppColors.secondaryColor,
            backgroundColor: Colors.grey.shade800,
            highlightedColor: Colors.white,
            boxShadow: BoxShadow(color: Colors.white, blurRadius: 10),
            baseColor: AppColors.secondaryColor,
          )
        : Container();
  }
}
