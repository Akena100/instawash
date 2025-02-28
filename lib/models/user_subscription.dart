import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserSubscription extends Equatable {
  final String id;
  final String userId; // User ID field
  final String serviceId;
  final String subServiceId;
  final String moreServiceId;
  final String category;
  final double price;
  final double discount;
  final DateTime createdAt; // Creation DateTime field
  final DateTime endDate; // End DateTime field

  const UserSubscription({
    required this.id,
    required this.userId, // Initialize userId
    required this.serviceId,
    required this.subServiceId,
    required this.moreServiceId,
    required this.category,
    required this.price,
    required this.discount,
    required this.createdAt, // Initialize createdAt
    required this.endDate, // Initialize endDate
  });

  // Convert JSON to UserSubscription object
  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'],
      userId: json['userId'], // Extract userId from JSON
      serviceId: json['serviceId'],
      subServiceId: json['subServiceId'],
      moreServiceId: json['moreServiceId'],
      category: json['category'],
      price: json['price'].toDouble(),
      discount: json['discount'].toDouble(),
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              json['createdAt']), // Handle DateTime conversion for createdAt
      endDate: (json['endDate'] is Timestamp)
          ? (json['endDate'] as Timestamp).toDate()
          : DateTime.parse(
              json['endDate']), // Handle DateTime conversion for endDate
    );
  }

  // Convert UserSubscription object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId, // Include userId in the JSON
      'serviceId': serviceId,
      'subServiceId': subServiceId,
      'moreServiceId': moreServiceId,
      'category': category,
      'price': price,
      'discount': discount,
      'createdAt': createdAt.toIso8601String(), // Convert createdAt to string
      'endDate': endDate.toIso8601String(), // Convert endDate to string
    };
  }

  // Convert Firestore snapshot to UserSubscription object
  factory UserSubscription.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return UserSubscription(
      id: snapshot.id,
      userId: data['userId'], // Extract userId from snapshot
      serviceId: data['serviceId'],
      subServiceId: data['subServiceId'],
      moreServiceId: data['moreServiceId'],
      category: data['category'],
      price: data['price'].toDouble(),
      discount: data['discount'].toDouble(),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              data['createdAt']), // Convert createdAt from Firestore
      endDate: data['endDate'] is Timestamp
          ? (data['endDate'] as Timestamp).toDate()
          : DateTime.parse(data['endDate']), // Convert endDate from Firestore
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId, // Include userId for comparison
        serviceId,
        subServiceId,
        moreServiceId,
        category,
        price,
        discount,
        createdAt, // Include createdAt for comparison
        endDate, // Include endDate for comparison
      ];
}
