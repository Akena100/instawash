import 'package:cloud_firestore/cloud_firestore.dart';

class Water {
  final String id;
  final String username;
  final String password;
  final String action;
  final String provider;
  final String phone;
  final String amount;
  final String account;
  final String location;
  final String reference;

  Water({
    required this.id,
    required this.username,
    required this.password,
    required this.action,
    required this.provider,
    required this.phone,
    required this.amount,
    required this.account,
    required this.location,
    required this.reference,
  });

  // Step 2: Implement fromJson
  factory Water.fromJson(Map<String, dynamic> json) {
    return Water(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      action: json['action'],
      provider: json['provider'],
      phone: json['phone'],
      amount: json['amount'],
      account: json['account'],
      location: json['location'],
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
      'account': account,
      'location': location,
      'reference': reference,
    };
  }

  // Step 4: Implement fromSnapshot (for Firebase)
  factory Water.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Water.fromJson(data);
  }
}
