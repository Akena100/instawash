import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart';

class SpecificLocationMap extends StatefulWidget {
  const SpecificLocationMap({super.key});

  @override
  _SpecificLocationMapState createState() => _SpecificLocationMapState();
}

class _SpecificLocationMapState extends State<SpecificLocationMap> {
  late GoogleMapController _mapController;
  final LatLng _targetLocation = LatLng(0.3605423074961499, 32.599455245105005);
  String? _locationName;
  BitmapDescriptor? _customMarker;
  final MarkerId _markerId = const MarkerId('targetLocation');

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    _fetchAddress();
  }

  // Load the custom marker from assets
  Future<void> _loadCustomMarker() async {
    final ByteData byteData = await rootBundle.load('assets/png/logo.png');
    final Uint8List bytes = byteData.buffer.asUint8List();
    final BitmapDescriptor markerIcon =
        BitmapDescriptor.bytes(bytes, width: 48, height: 48);

    setState(() {
      _customMarker = markerIcon;
    });
  }

  // Fetch address using reverse geocoding
  Future<void> _fetchAddress() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _targetLocation.latitude,
        _targetLocation.longitude,
      );
      Placemark place = placemarks.first;
      setState(() {
        _locationName =
            "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      });

      // Show the InfoWindow automatically when address is fetched
      _mapController.showMarkerInfoWindow(_markerId);
    } catch (e) {
      setState(() {
        _locationName = "Unknown Location";
      });
      print('Error fetching address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _targetLocation,
            zoom: 18.0,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;

            // Delay a bit to allow marker rendering before showing InfoWindow
            Future.delayed(const Duration(milliseconds: 500), () {
              _mapController.showMarkerInfoWindow(_markerId);
            });
          },
          markers: {
            if (_customMarker != null)
              Marker(
                markerId: _markerId,
                position: _targetLocation,
                icon: _customMarker!,
                infoWindow: InfoWindow(
                  title: 'Instawash Uganda',
                ),
              ),
          },
        ),
        if (_locationName == null)
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
