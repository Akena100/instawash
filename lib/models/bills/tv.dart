import 'package:cloud_firestore/cloud_firestore.dart';

class TV {
  final String id; // Optional id field
  final String username;
  final String password;
  final String action;
  final String provider;
  final String phone;
  final String amount;
  final String account;

  TV({
    required this.id, // Optional in the constructor
    required this.username,
    required this.password,
    required this.action,
    required this.provider,
    required this.phone,
    required this.amount,
    required this.account,
  });

  // Step 2: Implement fromJson
  factory TV.fromJson(Map<String, dynamic> json) {
    return TV(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      action: json['action'],
      provider: json['provider'],
      phone: json['phone'],
      amount: json['amount'],
      account: json['account'],
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
      'account': account,
    };
  }

  // Step 4: Implement fromSnapshot (for Firebase)
  factory TV.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return TV.fromJson(data);
  }
}
