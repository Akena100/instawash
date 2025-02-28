import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class MoreService extends Equatable {
  final String id;
  final String serviceId;
  final String subServiceId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  bool? isSelected;

  MoreService({
    required this.id,
    required this.serviceId,
    required this.subServiceId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required isSelected,
  });

  // Convert JSON to MoreService object
  factory MoreService.fromJson(Map<String, dynamic> json) {
    return MoreService(
        id: json['id'],
        serviceId: json['serviceId'],
        subServiceId: json['subServiceId'],
        name: json['name'],
        description: json['description'],
        price: json['price'].toDouble(),
        imageUrl: json['imageUrl'],
        isSelected: json['isSelected']);
  }

  // Convert MoreService object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'subServiceId': subServiceId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isSelected': isSelected
    };
  }

  // Convert Firestore snapshot to MoreService object
  factory MoreService.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return MoreService(
        id: snapshot.id,
        serviceId: data['serviceId'],
        subServiceId: data['subServiceId'],
        name: data['name'],
        description: data['description'],
        price: data['price'].toDouble(),
        imageUrl: data['imageUrl'],
        isSelected: data['isSelected']);
  }

  @override
  List<Object?> get props => [
        id,
        serviceId,
        subServiceId,
        name,
        description,
        price,
        imageUrl,
        isSelected
      ];
}
