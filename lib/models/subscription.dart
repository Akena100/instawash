import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Subscription extends Equatable {
  final String id;
  final String serviceId;
  final String subServiceId;
  final String moreServiceId;
  final String category;

  final double discount;
  final int numberOfDay; // New field

  const Subscription({
    required this.id,
    required this.serviceId,
    required this.subServiceId,
    required this.moreServiceId,
    required this.category,
    required this.discount,
    required this.numberOfDay, // Include in constructor
  });

  // Convert JSON to Subscription object
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      serviceId: json['serviceId'],
      subServiceId: json['subServiceId'],
      moreServiceId: json['moreServiceId'],
      category: json['category'],

      discount: json['discount'].toDouble(),
      numberOfDay: json['numberOfDay'], // Handle the new field
    );
  }

  // Convert Subscription object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'subServiceId': subServiceId,
      'moreServiceId': moreServiceId,
      'category': category,

      'discount': discount,
      'numberOfDay': numberOfDay, // Include in toJson
    };
  }

  // Convert Firestore snapshot to Subscription object
  factory Subscription.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Subscription(
      id: snapshot.id,
      serviceId: data['serviceId'],
      subServiceId: data['subServiceId'],
      moreServiceId: data['moreServiceId'],
      category: data['category'],

      discount: data['discount'].toDouble(),
      numberOfDay: data['numberOfDay'], // Retrieve the new field from Firestore
    );
  }

  @override
  List<Object?> get props => [
        id,
        serviceId,
        subServiceId,
        moreServiceId,
        category,

        discount,
        numberOfDay, // Include in comparison
      ];
}
