import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  // Existing fields
  final String id;
  final String userId;
  final String subscriptionId;
  final String subscriptionName;
  final String serviceName;
  final String subServiceId;
  final String moreServiceId;
  final double price;
  final String status;
  final DateTime date;
  final String additionalInfo;
  final String location;
  final int durationInMinutes;
  final DateTime startDate;
  final DateTime completeDate;
  final String comment;
  final double latitude;
  final double longitude;
  final DateTime savedTime;
  final TimeOfDay time;

  // New fields
  final String dispatchId;
  final String type;
  final DateTime? driverStartTime; // New field for driver's start time
  final DateTime? driverStopTime; // New field for driver's stop time
  final double? rating; // New field for storing rating (optional)
  final String
      customerCare; // New field for the customer care agent's name or ID

  // Constructor including the new fields
  const Booking({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.subscriptionName,
    required this.serviceName,
    required this.subServiceId,
    required this.moreServiceId,
    required this.price,
    required this.status,
    required this.date,
    required this.additionalInfo,
    required this.location,
    required this.durationInMinutes,
    required this.startDate,
    required this.completeDate,
    required this.comment,
    required this.latitude,
    required this.longitude,
    required this.savedTime,
    required this.time,
    required this.type,
    required this.dispatchId, // Adding dispatchId to the constructor
    this.driverStartTime, // Optional: driver start time
    this.driverStopTime, // Optional: driver stop time
    this.rating, // Optional: rating
    required this.customerCare, // New field for customer care
  });

  // Convert JSON to Booking object
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['userId'],
      subscriptionId: json['subscriptionId'],
      subscriptionName: json['subscriptionName'],
      serviceName: json['serviceName'],
      subServiceId: json['subServiceId'],
      moreServiceId: json['moreServiceId'],
      price: json['price'].toDouble(),
      status: json['status'],
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.parse(json['date']),
      additionalInfo: json['additionalInfo'],
      location: json['location'],
      durationInMinutes: json['durationInMinutes'],
      startDate: json['startDate'] is Timestamp
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.parse(json['startDate']),
      completeDate: json['completeDate'] is Timestamp
          ? (json['completeDate'] as Timestamp).toDate()
          : DateTime.parse(json['completeDate']),
      comment: json['comment'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      savedTime: json['savedTime'] is Timestamp
          ? (json['savedTime'] as Timestamp).toDate()
          : DateTime.parse(json['savedTime']),
      time: json['time'] != null
          ? TimeOfDay(
              hour: json['time']['hour'],
              minute: json['time']['minute'],
            )
          : const TimeOfDay(hour: 0, minute: 0),
      type: json['type'],
      dispatchId: json['dispatchId'], // Extracting dispatchId from JSON
      driverStartTime: json['driverStartTime'] != null
          ? (json['driverStartTime'] as Timestamp).toDate()
          : null, // Handling driver start time
      driverStopTime: json['driverStopTime'] != null
          ? (json['driverStopTime'] as Timestamp).toDate()
          : null, // Handling driver stop time
      rating: json['rating']?.toDouble(), // Handling rating
      customerCare: json['customerCare'] ?? '', // Extracting customer care
    );
  }

  // Convert Booking object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subscriptionId': subscriptionId,
      'subscriptionName': subscriptionName,
      'serviceName': serviceName,
      'subServiceId': subServiceId,
      'moreServiceId': moreServiceId,
      'price': price,
      'status': status,
      'date': date.toIso8601String(),
      'additionalInfo': additionalInfo,
      'location': location,
      'durationInMinutes': durationInMinutes,
      'startDate': startDate.toIso8601String(),
      'completeDate': completeDate.toIso8601String(),
      'comment': comment,
      'latitude': latitude,
      'longitude': longitude,
      'savedTime': savedTime.toIso8601String(),
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
      'type': type,
      'dispatchId': dispatchId, // Including dispatchId in the toJson method
      'driverStartTime':
          driverStartTime?.toIso8601String(), // Saving driver start time
      'driverStopTime':
          driverStopTime?.toIso8601String(), // Saving driver stop time
      'rating': rating, // Storing the rating value
      'customerCare': customerCare, // Storing the customer care agent's info
    };
  }

  // Convert Firestore snapshot to Booking object
  factory Booking.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Booking(
      id: snapshot.id,
      userId: data['userId'],
      subscriptionId: data['subscriptionId'],
      subscriptionName: data['subscriptionName'],
      serviceName: data['serviceName'],
      subServiceId: data['subServiceId'],
      moreServiceId: data['moreServiceId'],
      price: data['price'].toDouble(),
      status: data['status'],
      date: data['date'] is Timestamp
          ? (data['date'] as Timestamp).toDate()
          : DateTime.parse(data['date']),
      additionalInfo: data['additionalInfo'],
      location: data['location'],
      durationInMinutes: data['durationInMinutes'],
      startDate: data['startDate'] is Timestamp
          ? (data['startDate'] as Timestamp).toDate()
          : DateTime.parse(data['startDate']),
      completeDate: data['completeDate'] is Timestamp
          ? (data['completeDate'] as Timestamp).toDate()
          : DateTime.parse(data['completeDate']),
      comment: data['comment'],
      latitude: data['latitude'].toDouble(),
      longitude: data['longitude'].toDouble(),
      savedTime: data['savedTime'] is Timestamp
          ? (data['savedTime'] as Timestamp).toDate()
          : DateTime.parse(data['savedTime']),
      time: data['time'] != null
          ? TimeOfDay(
              hour: data['time']['hour'],
              minute: data['time']['minute'],
            )
          : const TimeOfDay(hour: 0, minute: 0),
      type: data['type'],
      dispatchId:
          data['dispatchId'], // Adding dispatchId from Firestore snapshot
      driverStartTime: data['driverStartTime'] != null
          ? (data['driverStartTime'] as Timestamp).toDate()
          : null, // Retrieving driver start time
      driverStopTime: data['driverStopTime'] != null
          ? (data['driverStopTime'] as Timestamp).toDate()
          : null, // Retrieving driver stop time
      rating: data['rating']?.toDouble(), // Retrieving rating
      customerCare: data['customerCare'] ?? '', // Retrieving customer care info
    );
  }

  // Equatable props including the new field
  @override
  List<Object?> get props => [
        id,
        userId,
        subscriptionId,
        subscriptionName,
        serviceName,
        subServiceId,
        moreServiceId,
        price,
        status,
        date,
        additionalInfo,
        location,
        durationInMinutes,
        startDate,
        completeDate,
        comment,
        latitude,
        longitude,
        savedTime,
        time,
        type,
        dispatchId, // Including dispatchId in the list of props
        driverStartTime, // Including driver start time in props
        driverStopTime, // Including driver stop time in props
        rating, // Including rating in props
        customerCare,
      ];
}
