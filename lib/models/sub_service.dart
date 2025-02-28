import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SubService extends Equatable {
  final String id;
  final String serviceId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  const SubService({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  // Convert JSON to SubService object
  factory SubService.fromJson(Map<String, dynamic> json) {
    return SubService(
      id: json['id'],
      serviceId: json['serviceId']! as String,
      name: json['name']! as String,
      description: json['description']! as String,
      price: json['price']!.toDouble() as double,
      imageUrl: json['imageUrl']! as String,
    );
  }

  // Convert SubService object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  // Convert Firestore snapshot to SubService object
  factory SubService.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return SubService(
      id: snapshot.id,
      serviceId: data['serviceId'],
      name: data['name'],
      description: data['description'],
      price: data['price'].toDouble(),
      imageUrl: data['imageUrl'],
    );
  }

  @override
  List<Object?> get props =>
      [id, serviceId, name, description, price, imageUrl];
}
