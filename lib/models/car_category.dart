import 'package:cloud_firestore/cloud_firestore.dart';

class CarCategory {
  String id;
  String name;
  String description;
  double price;
  String imageUrl;

  CarCategory(
      {required this.id,
      required this.name,
      required this.description,
      required this.price,
      required this.imageUrl});

  // fromJson method
  factory CarCategory.fromJson(Map<String, dynamic> json) {
    return CarCategory(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: json['price'].toDouble(),
        imageUrl: json['imageUrl']);
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl
    };
  }

  // fromSnapshot method
  factory CarCategory.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return CarCategory(
        id: data['id'],
        name: data['name'],
        description: data['description'],
        price: data['price'].toDouble(),
        imageUrl: data['imageUrl']);
  }
}
