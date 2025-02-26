import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentRequest {
  String username;
  String password;
  String action;
  int amount;
  String currency;
  String phone;
  String reference;
  String reason;

  PaymentRequest({
    required this.username,
    required this.password,
    required this.action,
    required this.amount,
    required this.currency,
    required this.phone,
    required this.reference,
    required this.reason,
  });

  // Create a PaymentRequest object from JSON data
  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      username: json['username'],
      password: json['password'],
      action: json['action'],
      amount: json['amount'],
      currency: json['currency'],
      phone: json['phone'],
      reference: json['reference'],
      reason: json['reason'],
    );
  }

  // Convert PaymentRequest object to JSON data
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'action': action,
      'amount': amount,
      'currency': currency,
      'phone': phone,
      'reference': reference,
      'reason': reason,
    };
  }

  // Create a PaymentRequest object from Firebase DocumentSnapshot
  factory PaymentRequest.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return PaymentRequest.fromJson(data);
  }
}

// Usage example
