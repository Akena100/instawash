import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SelectedMoreService extends Equatable {
  final String id;
  final String serviceId;
  final String subServiceId;
  final String moreServiceId;
  final String userId; // Added userId
  final String bookingId; // Added bookingId
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  const SelectedMoreService({
    required this.id,
    required this.serviceId,
    required this.subServiceId,
    required this.moreServiceId,
    required this.userId,
    required this.bookingId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  // Convert JSON to SelectedMoreService object
  factory SelectedMoreService.fromJson(Map<String, dynamic> json) {
    return SelectedMoreService(
      id: json['id'],
      serviceId: json['serviceId'],
      subServiceId: json['subServiceId'],
      moreServiceId: json['moreServiceId'],
      userId: json['userId'],
      bookingId: json['bookingId'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
    );
  }

  // Convert SelectedMoreService object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'subServiceId': subServiceId,
      'moreServiceId': moreServiceId,
      'userId': userId,
      'bookingId': bookingId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  // Convert Firestore snapshot to SelectedMoreService object
  factory SelectedMoreService.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return SelectedMoreService(
      id: snapshot.id,
      serviceId: data['serviceId'],
      subServiceId: data['subServiceId'],
      moreServiceId: data['moreServiceId'],
      userId: data['userId'],
      bookingId: data['bookingId'],
      name: data['name'],
      description: data['description'],
      price: data['price'].toDouble(),
      imageUrl: data['imageUrl'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        serviceId,
        subServiceId,
        userId,
        bookingId,
        name,
        description,
        price,
        imageUrl,
      ];
}
