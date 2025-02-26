import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String address;
  final String city;
  final String country;
  final String phoneNumber;
  final String role;
  final String imageUrl;

  const UserModel({
    this.id = '',
    this.fullName = '',
    this.email = '',
    this.address = '',
    this.city = '',
    this.country = '',
    this.phoneNumber = '',
    this.role = '',
    this.imageUrl = '',
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? address,
    String? city,
    String? country,
    String? phoneNumber,
    String? role,
    String? imageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      city: city ?? this.city,
      country: country ?? this.country,
      address: address ?? this.address,
      role: role ?? this.role,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // fromSnapshot method for Firestore data
  factory UserModel.fromSnapshot(DocumentSnapshot snap) {
    return UserModel(
      id: snap['id'] ?? '',
      fullName: snap['fullName'] ?? '',
      email: snap['email'] ?? '',
      address: snap['address'] ?? '',
      city: snap['city'] ?? '',
      country: snap['country'] ?? '',
      phoneNumber: snap['phoneNumber'] ?? '',
      role: snap['role'] ?? '',
      imageUrl: snap['imageUrl'] ?? '',
    );
  }

  // fromMap method for converting Map<String, dynamic> to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, Object> toDocument() {
    return {
      'fullName': fullName,
      'email': email,
      'address': address,
      'city': city,
      'country': country,
      'phoneNumber': phoneNumber,
      'id': id,
      'role': role,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        address,
        city,
        country,
        phoneNumber,
        role,
        imageUrl
      ];
}
