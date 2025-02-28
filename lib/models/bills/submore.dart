import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SubMore extends Equatable {
  final String id;
  final String serviceId;
  final String name;
  final String description;
  final String imageUrl;

  const SubMore({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  // Convert JSON to SubMore object
  factory SubMore.fromJson(Map<String, dynamic> json) {
    return SubMore(
      id: json['id'],
      serviceId: json['serviceId'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }

  // Convert SubMore object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  // Convert Firestore snapshot to SubMore object
  factory SubMore.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return SubMore(
      id: snapshot.id,
      serviceId: data['serviceId'],
      name: data['name'],
      description: data['description'],
      imageUrl: data['imageUrl'],
    );
  }

  @override
  List<Object?> get props => [id, serviceId, name, description, imageUrl];
}
