import 'package:cloud_firestore/cloud_firestore.dart';

class Key {
  final String id;
  final String name;
  final String clientId;
  final String clientSecret;

  Key({
    required this.id,
    required this.name,
    required this.clientId,
    required this.clientSecret,
  });

  factory Key.fromJson(Map<String, dynamic> json) {
    return Key(
        id: json['id'],
        name: json['name'],
        clientId: json['clientId'],
        clientSecret: json['clientSecret']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'clientId': clientId,
      'clientSecret': clientSecret
    };
  }

  factory Key.fromSnapshot(DocumentSnapshot snapshot) {
    return Key(
        id: snapshot['id'],
        name: snapshot['name'],
        clientId: snapshot['clientId'],
        clientSecret: snapshot['clientSecret']);
  }
}
