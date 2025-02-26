import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:instawash/models/booking.dart';

class DriverTrackingPage extends StatefulWidget {
  final Booking booking;

  const DriverTrackingPage({super.key, required this.booking});

  @override
  _DriverTrackingPageState createState() => _DriverTrackingPageState();
}

class _DriverTrackingPageState extends State<DriverTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  LatLng? _driverLocation;
  final LatLng _customerLocation = const LatLng(0.3476, 32.5825); // Kampala

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  BitmapDescriptor? _driverIcon;
  double _distanceInKm = 0.0;
  int _estimatedTime = 0; // ETA in minutes

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    _trackDriverLocation();
  }

  // Load custom driver marker icon
  void _loadCustomMarker() async {
    _driverIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/driver_icon.png', // Ensure you have this icon in your assets folder
    );
  }

  // Track driver location in real-time from Firebase
  void _trackDriverLocation() {
    _database
        .child('drivers/${widget.booking.dispatchId}/location')
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        double lat = data['latitude'];
        double lng = data['longitude'];
        setState(() {
          _driverLocation = LatLng(lat, lng);
          _updateMarkers();
          _updateRoute();
          _calculateDistanceAndETA();
          _moveCameraToFitRoute();
        });
      }
    });
  }

  // Update markers on the map
  void _updateMarkers() {
    _markers.clear();
    if (_driverLocation != null) {
      _markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: _driverLocation!,
        icon: _driverIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "Driver"),
      ));
    }

    _markers.add(const Marker(
      markerId: MarkerId('customer'),
      position: LatLng(0.3476, 32.5825),
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: "Customer Location"),
    ));
  }

  // Draw polyline (route)
  void _updateRoute() {
    if (_driverLocation == null) return;

    _polylines.clear();
    _polylines.add(Polyline(
      polylineId: const PolylineId("route"),
      color: Colors.blue,
      width: 5,
      points: [
        _driverLocation!,
        _customerLocation,
      ],
    ));
  }

  // Calculate distance and ETA
  void _calculateDistanceAndETA() {
    if (_driverLocation == null) return;

    double distance = Geolocator.distanceBetween(
          _driverLocation!.latitude,
          _driverLocation!.longitude,
          _customerLocation.latitude,
          _customerLocation.longitude,
        ) /
        1000; // Convert to kilometers

    setState(() {
      _distanceInKm = distance;
      _estimatedTime = (distance / 0.5).ceil(); // Assuming 30 km/h speed
    });
  }

  // Adjust camera to fit route
  Future<void> _moveCameraToFitRoute() async {
    if (_driverLocation == null) return;
    final GoogleMapController controller = await _controller.future;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        _driverLocation!.latitude < _customerLocation.latitude
            ? _driverLocation!.latitude
            : _customerLocation.latitude,
        _driverLocation!.longitude < _customerLocation.longitude
            ? _driverLocation!.longitude
            : _customerLocation.longitude,
      ),
      northeast: LatLng(
        _driverLocation!.latitude > _customerLocation.latitude
            ? _driverLocation!.latitude
            : _customerLocation.latitude,
        _driverLocation!.longitude > _customerLocation.longitude
            ? _driverLocation!.longitude
            : _customerLocation.longitude,
      ),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Tracking')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.black87,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Distance: ${_distanceInKm.toStringAsFixed(2)} km",
                    style: const TextStyle(color: Colors.white)),
                Text("ETA: $_estimatedTime min",
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: _driverLocation == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _customerLocation,
                      zoom: 14,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
