import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:instawash/models/booking.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClientTrackingScreen extends StatefulWidget {
  final Booking booking;

  const ClientTrackingScreen({super.key, required this.booking});

  @override
  _ClientTrackingScreenState createState() => _ClientTrackingScreenState();
}

class _ClientTrackingScreenState extends State<ClientTrackingScreen> {
  late GoogleMapController mapController;
  LatLng? driverLocation;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  String status = "Driving"; // Initial status
  double? lastLat;
  double? lastLng;
  DateTime? lastUpdateTime;
  final String googleApiKey =
      "AIzaSyAe3JKNpmh5YfDuNBEuuUlbliS7i0tP7bQ"; // Add your API Key here
  final FirebaseDatabase database = FirebaseDatabase.instance;
  bool isLoading = true;
  String distanceText = "Calculating...";
  String durationText = "Calculating...";
  bool hasArrived = false;

  @override
  void initState() {
    super.initState();
    _listenToDriverLocation();
  }

  void _listenToDriverLocation() {
    database
        .ref('tracking/${widget.booking.dispatchId}')
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map?;
        if (data != null) {
          double? lat = data['latitude']?.toDouble();
          double? lng = data['longitude']?.toDouble();

          if (lat != null && lng != null) {
            // Check if the position has changed
            if (lat == lastLat && lng == lastLng) {
              // Check if it's been 1 minute since the last update
              if (lastUpdateTime != null &&
                  DateTime.now().difference(lastUpdateTime!).inMinutes >= 1) {
                setState(() {
                  status =
                      "Traffic"; // Update status to "Traffic" if position hasn't changed for 1 minute
                });
              }
            } else {
              setState(() {
                status =
                    "Driving"; // Update status to "Driving" if the position has changed
              });
            }

            // Update the driver's location and last update time
            setState(() {
              driverLocation = LatLng(lat, lng);
              lastLat = lat;
              lastLng = lng;
              lastUpdateTime = DateTime.now(); // Update the last update time
              _updateMarkers();
              _fetchRoute();
            });

            _fitMapToMarkers();
          }
        }
      }
    });
  }

  void _updateMarkers() {
    setState(() {
      markers.clear();
      if (driverLocation != null) {
        markers.add(Marker(
          markerId: const MarkerId("driver"),
          position: driverLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      }
      markers.add(Marker(
        markerId: const MarkerId("destination"),
        position: LatLng(widget.booking.latitude,
            widget.booking.longitude), // Using booking destination
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    });
  }

  Future<void> _fetchRoute() async {
    if (driverLocation == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleApiKey,
      request: PolylineRequest(
        origin:
            PointLatLng(driverLocation!.latitude, driverLocation!.longitude),
        destination: PointLatLng(widget.booking.latitude,
            widget.booking.longitude), // Using booking destination
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

      if (decodedJson["routes"] != null && decodedJson["routes"].isNotEmpty) {
        final route = decodedJson["routes"][0];
        final leg = route["legs"][0];

        final distance = leg["distance"]["text"];
        final duration = leg["duration"]["text"];

        setState(() {
          distanceText = distance;
          durationText = duration;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        const BoxShadow(color: Colors.black26, blurRadius: 5)
                      ],
                    ),
                    child: Column(
                      children: [
                        Text("Distance: $distanceText",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text("ETA: $durationText",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Status: $status",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
