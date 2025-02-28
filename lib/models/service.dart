import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final DateTime createDate; // Add createDate field

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.createDate, // Add createDate to constructor
  });

  // Convert JSON to Service object
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      createDate: (json['createDate'] as Timestamp).toDate(),
    );
  }

  // Convert Service object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createDate': Timestamp.fromDate(createDate), // Add createDate to JSON
    };
  }

  // Convert Firestore snapshot to Service object
  factory Service.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Service(
      id: snapshot.id,
      name: data['name'],
      description: data['description'],
      imageUrl: data['imageUrl'],
      createDate: (data['createDate'] as Timestamp)
          .toDate(), // Parse createDate from snapshot
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        createDate
      ]; // Include createDate in props
}
