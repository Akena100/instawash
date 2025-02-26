import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/models/booking.dart';

import 'package:instawash/presentation/widgets/track2.dart';

import 'package:slider_button/slider_button.dart';

class JourneyButton1 extends StatefulWidget {
  final Booking booking;

  const JourneyButton1({super.key, required this.booking});

  @override
  JourneyButtonState createState() => JourneyButtonState();
}

class JourneyButtonState extends State<JourneyButton1> {
  bool _buttonVisible = true;

  @override
  Widget build(BuildContext context) {
    return _buttonVisible
        ? SliderButton(
            action: () async {
              setState(() => _buttonVisible = false);

              await Get.to(() => ClientTrackingScreen(booking: widget.booking));

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
              "Track Driver!",
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
