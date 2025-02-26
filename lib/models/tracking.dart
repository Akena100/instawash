import 'package:cloud_firestore/cloud_firestore.dart';

class Tracking {
  String id;
  double latitude;
  double longitude;
  Timestamp startTime;
  Timestamp arrivalTime;

  Tracking({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    required this.arrivalTime,
  });

  // Convert a Tracking object to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'startTime': startTime,
      'arrivalTime': arrivalTime,
    };
  }

  factory Tracking.fromJson(Map<String, dynamic> json) {
    return Tracking(
      id: json['id'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      startTime: json['startTime'] ?? Timestamp.now(),
      arrivalTime: json['arrivalTime'] ?? Timestamp.now(),
    );
  }
}
