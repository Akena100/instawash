import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:instawash/models/booking.dart';
import 'package:http/http.dart' as http;
import 'package:instawash/models/notifications.dart';
import 'package:instawash/models/repo.dart';
import 'package:instawash/presentation/widgets/button_slider_end_trip.dart';
import 'dart:convert';

import 'package:instawash/server_key.dart';
import 'package:uuid/uuid.dart';

final String googleApiKey =
    "AIzaSyAe3JKNpmh5YfDuNBEuuUlbliS7i0tP7bQ"; // Add your API Key here

class TrackingScreen extends StatefulWidget {
  final Booking booking;

  const TrackingScreen({super.key, required this.booking});

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late GoogleMapController mapController;
  LatLng? driverLocation;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  String distanceText = "Calculating...";
  String durationText = "Calculating...";
  bool hasArrived = false;
  String status = "Driving"; // Add status variable
  double lastLat = 0.0, lastLng = 0.0;
  DateTime? lastUpdateTime; // Add a timestamp to track last update

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Method to get the current location of the driver
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
    ));
    setState(() {
      driverLocation = LatLng(position.latitude, position.longitude);
      isLoading = false;
      lastLat = position.latitude;
      lastLng = position.longitude;
      lastUpdateTime = DateTime.now(); // Save the time of the first update
      _updateMarkers();
      _fetchRoute();
      _saveStartTime();
    });

    _updateDriverLocationToFirebase(
        position); // Update Firebase with the initial position
    _listenToDriverLocation();
  }

  // Method to update the driver's location in Firebase
  void _updateDriverLocationToFirebase(Position position) {
    database.ref('tracking/${widget.booking.dispatchId}').update({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now()
          .millisecondsSinceEpoch, // Add a timestamp for each update
    });
  }

  // Firebase listener for real-time updates
  void _listenToDriverLocation() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    ).listen((Position position) {
      // Update Firebase and the map with the new location
      _updateDriverLocationToFirebase(position);
      setState(() {
        driverLocation = LatLng(position.latitude, position.longitude);
        _updateMarkers();
        _fetchRoute();
      });
      _fitMapToMarkers();
      mapController.animateCamera(
        CameraUpdate.newLatLng(driverLocation!),
      );
      _checkArrival();
    });
  }

  final MarkerId markerId1 = MarkerId('driver');
  final MarkerId markerId2 = MarkerId('destination');

  // Method to update markers on the map
  void _updateMarkers() {
    setState(() {
      markers.clear();

      // Driver Marker
      if (driverLocation != null) {
        Marker driverMarker = Marker(
          markerId: const MarkerId("driver"),
          position: driverLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: "Driver",
            snippet:
                "Your driver is here", // You can add more details here if you want
          ),
        );
        markers.add(driverMarker);
      }

      // Client (Destination) Marker
      Marker clientMarker = Marker(
        markerId: const MarkerId("destination"),
        position: LatLng(widget.booking.latitude, widget.booking.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: widget.booking.location,
          snippet:
              "Destination Address", // Add the client-specific details here
        ),
      );
      markers.add(clientMarker);
    });

    // Ensure the map is fully initialized before showing info windows
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show info windows for both markers
      mapController.showMarkerInfoWindow(const MarkerId("driver"));
      mapController.showMarkerInfoWindow(const MarkerId("destination"));
    });
  }

  // Method to fetch the route from the driver's location to the destination
  Future<void> _fetchRoute() async {
    if (driverLocation == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleApiKey,
      request: PolylineRequest(
        origin:
            PointLatLng(driverLocation!.latitude, driverLocation!.longitude),
        destination:
            PointLatLng(widget.booking.latitude, widget.booking.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      setState(() {
        polylines.clear();
        polylines.add(Polyline(
          polylineId: const PolylineId("route"),
          points: result.points
              .map((e) => LatLng(e.latitude, e.longitude))
              .toList(),
          color: Colors.blue,
          width: 5,
        ));
      });
    }

    await _calculateDistanceAndDuration();
  }

  // Method to calculate the distance and duration from the driver to the destination
  // Variables to store the last known route distance in meters
  double lastRouteDistance = 0.0;

  Future<void> _calculateDistanceAndDuration() async {
    if (driverLocation == null) return;

    final String origin =
        "${driverLocation!.latitude},${driverLocation!.longitude}";
    final String destination =
        "${widget.booking.latitude},${widget.booking.longitude}";

    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final decodedJson = json.decode(response.body);

      // Log the entire response to check for issues
      print("API Response: $decodedJson");

      if (decodedJson["routes"] != null && decodedJson["routes"].isNotEmpty) {
        final route = decodedJson["routes"][0];
        final leg = route["legs"][0];

        final distance = leg["distance"]["value"]; // distance in meters
        final duration = leg["duration"]["text"];

        // Log the distance and duration to ensure they are correctly fetched
        print("Distance: $distance meters, Duration: $duration");

        // Update the distance text (in meters)
        setState(() {
          distanceText = "$distance meters"; // Display distance in meters
          durationText = duration;
        });

        // Update the last route distance
        lastRouteDistance = distance
            .toDouble(); // Store the current distance for next calculation
      } else {
        setState(() {
          distanceText = "Distance not available";
          durationText = "Duration not available";
        });
      }
    } catch (e) {
      print("Error calculating distance and duration: $e");
      setState(() {
        distanceText = "Error calculating distance";
        durationText = "Error calculating duration";
      });
    }
  }

  // Method to save the start time of the journey in Firestore
  void _saveStartTime() {
    final startTime =
        FieldValue.serverTimestamp(); // Firestore server timestamp

    firestore.collection('bookings').doc(widget.booking.id).update({
      'startDate': startTime,
    }).then((_) {
      print("Start time saved");
    }).catchError((error) {
      print("Error saving start time: $error");
    });
  }

  // Method to check if the driver has arrived at the destination
  void _checkArrival() async {
    if (driverLocation == null || hasArrived) return;

    double distance = Geolocator.distanceBetween(
      driverLocation!.latitude,
      driverLocation!.longitude,
      widget.booking.latitude,
      widget.booking.longitude,
    );

    if (distance <= 10) {
      hasArrived = true; // Mark as arrived so it doesn't trigger again

      // Save the complete time and update status
      _saveCompleteTime();

      // Send notification to the client
      await _sendNotification("We have arrived.");
    }
  }

  // Method to save the complete time when the driver arrives
  void _saveCompleteTime() {
    final completeTime =
        FieldValue.serverTimestamp(); // Firestore server timestamp

    firestore.collection('bookings').doc(widget.booking.id).update({
      'driverStopTime': completeTime,
      'status': 'Arrived', // Update the status to "Completed"
    }).then((_) {
      debugPrint("Complete time saved and booking status updated");
    }).catchError((error) {
      debugPrint("Error saving complete time: $error");
    });
  }

  // Notification Methods

  Future<String?> _getUserToken(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc['token']; // Fetch the token from Firestore
      }
    } catch (e) {
      debugPrint('Error getting user token: $e');
    }
    return null;
  }

  Future<void> _sendNotification(String message) async {
    String? token = await _getUserToken(
        widget.booking.userId); // Fetch the user token using booking info
    if (token != null) {
      await _sendPushNotification(token, message, widget.booking.userId);
    }
  }

  Future<void> _sendPushNotification(
      String token, String message, String userId) async {
    final t = GetServerKey();
    final accessToken = await t.servertoken(); // Await the result
    debugPrint('Access Token: $accessToken');
    debugPrint('Device Token: $token');
    try {
      final url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer $accessToken', // Add your Firebase server key here
      };
      final body = json.encode({
        'message': {
          'token': token,
          'notification': {
            'title': 'Driver Update',
            'body': message,
          },
        }
      });
      final response = await http.post(url, headers: headers, body: body);
      debugPrint(
          'Notification response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        Notifications notification = Notifications(
            id: Uuid().v4(),
            userId: userId,
            title: 'Driver Update',
            message: message,
            notificationDate: DateTime.now());
        Repo().addNotification(notification);
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  initialCameraPosition:
                      CameraPosition(target: driverLocation!, zoom: 14),
                  markers: markers,
                  polylines: polylines,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                ),
                Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: widget.booking.status == 'Arrived'
                        ? EndButton(
                            booking: widget.booking,
                          )
                        : Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                const BoxShadow(
                                    color: Colors.black26, blurRadius: 5)
                              ],
                            ),
                            child: Column(
                              children: [
                                Text("Distance: $distanceText",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                Text("ETA: $durationText",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )),
              ],
            ),
    );
  }

  void _fitMapToMarkers() {
    if (driverLocation == null) return;

    double lat1 = driverLocation!.latitude;
    double lng1 = driverLocation!.longitude;
    double lat2 = widget.booking.latitude;
    double lng2 = widget.booking.longitude;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(min(lat1, lat2), min(lng1, lng2)),
      northeast: LatLng(max(lat1, lat2), max(lng1, lng2)),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    });
  }
}
