import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/models/car_category_select.dart';
import 'package:instawash/presentation/screens/checkout.dart';
import 'models/sub_service.dart';
import 'models/more_service.dart';
import 'models/subscription.dart';

class MyHomePagez extends StatefulWidget {
  final String serviceId;
  final SubService subservice;
  final List<MoreService> selectedMoreServices;
  final double total;
  final DateTime? date;
  final TimeOfDay? time;
  final String uid;
  final Subscription? subscription;
  final String? number;
  final CarCategorySelect? selectedCar;

  const MyHomePagez({
    super.key,
    required this.serviceId,
    required this.subservice,
    required this.selectedMoreServices,
    required this.total,
    required this.time,
    required this.date,
    required this.uid,
    this.subscription,
    this.number,
    required this.selectedCar,
  });

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePagez> {
  final TextEditingController controller = TextEditingController();
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;
  String pickupAddress = '';
  double pickUpLongitude = 0;
  MarkerId markerId = const MarkerId('picked_location');

  double pickUpLatitude = 0;
  FocusNode focusNode = FocusNode();
  String imageUrl = '';
  final Set<Marker> _markers = {};
  final user = FirebaseAuth.instance.currentUser!;
  final String googleAPiKey = "AIzaSyAe3JKNpmh5YfDuNBEuuUlbliS7i0tP7bQ";

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
    _fetchDataFromFirestore();
  }

  Future<void> _fetchDataFromFirestore() async {
    QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (querySnapshot1.docs.isNotEmpty) {
      setState(() {
        imageUrl =
            querySnapshot1.docs[0]['imageUrl'] ?? ''; // Safely assign imageUrl
      });

      // Check if imageUrl is empty and assign a fallback URL
      if (imageUrl.isEmpty) {
        imageUrl =
            'https://firebasestorage.googleapis.com/v0/b/insta-wash01.appspot.com/o/car_category_images%2F1729838682862.jpg?alt=media&token=afdfe957-636b-4a6c-8b6d-5d80e7d1e7ae'; // Fallback image URL
      }

      if (_pickedLocation != null) {
        _setCustomMarker();
      }
    }
  }

  Future<Uint8List> _getBytesFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("Failed to load image");
    }
  }

  Future<Uint8List> _createRoundedMarker(Uint8List imageBytes) async {
    final ui.Codec codec = await ui.instantiateImageCodec(imageBytes,
        targetWidth: 120, targetHeight: 120);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final double size = 120.0;

    final Paint paint = Paint()..isAntiAlias = true;
    final Paint borderPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final ui.Rect rect = Rect.fromLTWH(0, 0, size, size);
    final ui.RRect roundedRect =
        ui.RRect.fromRectAndRadius(rect, Radius.circular(70));

    canvas.clipRRect(roundedRect);
    canvas.drawImage(image, Offset.zero, paint);
    canvas.drawRRect(roundedRect, borderPaint);

    final ui.Image roundedImage =
        await recorder.endRecording().toImage(size.toInt(), size.toInt());

    final ByteData? byteData =
        await roundedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _setCustomMarker() async {
    if (imageUrl.isNotEmpty && _pickedLocation != null) {
      try {
        final Uint8List markerImage = await _getBytesFromUrl(imageUrl);
        final Uint8List roundedImage = await _createRoundedMarker(markerImage);
        final BitmapDescriptor customIcon =
            BitmapDescriptor.bytes(roundedImage, height: 30, width: 30);

        setState(() {
          _markers.clear();
          _markers.add(
            Marker(
              markerId: markerId,
              position: _pickedLocation!,
              icon: customIcon,
              infoWindow: const InfoWindow(title: 'I am here!'),
            ),
          );
        });

        // Ensure InfoWindow is shown
        Future.delayed(const Duration(milliseconds: 500), () {
          _mapController?.showMarkerInfoWindow(markerId);
        });
      } catch (e) {
        print("Error loading marker image: $e");
      }
    }
  }

  Future<void> _setCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      setState(() {
        _pickedLocation = LatLng(position.latitude, position.longitude);
        pickupAddress =
            "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}";
        pickUpLongitude = position.longitude;
        pickUpLatitude = position.latitude;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _pickedLocation!, zoom: 15.0),
          ),
        );
      }

      // Set marker and show InfoWindow
      _setCustomMarker();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
            margin: EdgeInsets.only(right: 25),
            child: GooglePlaceAutoCompleteTextField(
              inputDecoration: const InputDecoration(
                hintText: 'Search here...',
              ),
              textEditingController: controller,
              googleAPIKey: googleAPiKey,
              debounceTime: 400,
              countries: ["ug"],
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction prediction) {
                if (prediction.lat != null && prediction.lng != null) {
                  setState(() {
                    // Safely parse latitude and longitude
                    _pickedLocation = LatLng(
                      double.tryParse(prediction.lat ?? '0') ??
                          0.0, // Fallback to 0 if invalid
                      double.tryParse(prediction.lng ?? '0') ??
                          0.0, // Fallback to 0 if invalid
                    );
                    pickUpLatitude =
                        double.tryParse(prediction.lat ?? '0') ?? 0.0;
                    pickUpLongitude =
                        double.tryParse(prediction.lng ?? '0') ?? 0.0;
                    pickupAddress =
                        prediction.description ?? 'No address found';
                  });
                  debugPrint(
                      '$pickUpLatitude + $pickUpLongitude + $pickupAddress');

                  // Ensure the controller and map controller are not null
                  if (_mapController != null && _pickedLocation != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: _pickedLocation!, zoom: 15.0),
                      ),
                    );
                  }

                  _setCustomMarker(); // This ensures the custom marker is set
                }
              },
              itemClick: (Prediction prediction) {
                controller.text = prediction.description ?? "";
                controller.selection =
                    TextSelection.collapsed(offset: controller.text.length);
                focusNode.unfocus();

                setState(() {
                  pickupAddress = prediction.description ?? 'No address found';
                  // Safely parse latitude and longitude
                  pickUpLatitude = double.tryParse(prediction.lat ?? '0') ??
                      0.0; // Fallback to 0 if invalid
                  pickUpLongitude = double.tryParse(prediction.lng ?? '0') ??
                      0.0; // Fallback to 0 if invalid
                });
              },
            )),
      ),
      body: _pickedLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: _pickedLocation!,
                    zoom: 12,
                  ),
                  onMapCreated: (controller) {
                    MapType.satellite;
                    _mapController = controller;

                    _mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: _pickedLocation!, zoom: 18.0),
                      ),
                    );
                  },
                  markers: _markers,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (pickupAddress.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  pickupAddress,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => Get.to(() => CheckoutPage(
                                uid: widget.uid,
                                serviceId: widget.serviceId,
                                subservice: widget.subservice,
                                total: widget.total,
                                selectedMoreServices:
                                    widget.selectedMoreServices,
                                subscription: widget.subscription,
                                selectedCar: widget.selectedCar!,
                                pickUpAddress: pickupAddress,
                                pickUpLatitude: pickUpLatitude,
                                pickUpLongitude: pickUpLongitude,
                                date: widget.date,
                                time: widget.time)),
                            icon: const Icon(Icons.arrow_forward,
                                color: Colors.black),
                            label: const Text(
                              "Continue",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
