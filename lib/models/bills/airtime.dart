import 'package:cloud_firestore/cloud_firestore.dart';

class Airtime {
  final String id;
  final String username;
  final String password;
  final String action;
  final String provider;
  final String phone;
  final String amount;
  final String reference;

  Airtime({
    required this.id,
    required this.username,
    required this.password,
    required this.action,
    required this.provider,
    required this.phone,
    required this.amount,
    required this.reference,
  });

  // Step 2: Implement fromJson
  factory Airtime.fromJson(Map<String, dynamic> json) {
    return Airtime(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      action: json['action'],
      provider: json['provider'],
      phone: json['phone'],
      amount: json['amount'],
      reference: json['reference'],
    );
  }

  // Step 3: Implement toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'action': action,
      'provider': provider,
      'phone': phone,
      'amount': amount,
      'reference': reference,
    };
  }

  // Step 4: Implement fromSnapshot (for Firebase)
  factory Airtime.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Airtime.fromJson(data);
  }
}
