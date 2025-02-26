import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TransactionsRecord extends Equatable {
  final String id;
  final String userId;
  final String transactionType; // e.g., "Payment", "Refund"
  final double amount;
  final String status; // e.g., "Success", "Failed"
  final String date;
  final String time;
  final String paymentMethod;
  final String orderId; // If applicable
  final String description; // Additional description

  const TransactionsRecord({
    required this.id,
    required this.userId,
    required this.transactionType,
    required this.amount,
    required this.status,
    required this.date,
    required this.time,
    required this.paymentMethod,
    required this.orderId,
    required this.description,
  });

  // Convert JSON to TransactionRecord object
  factory TransactionsRecord.fromJson(Map<String, dynamic> json) {
    return TransactionsRecord(
      id: json['id'],
      userId: json['userId'],
      transactionType: json['transactionType'],
      amount: json['amount'].toDouble(),
      status: json['status'],
      date: json['date'],
      time: json['time'],
      paymentMethod: json['paymentMethod'],
      orderId: json['orderId'],
      description: json['description'],
    );
  }

  // Convert TransactionRecord object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'transactionType': transactionType,
      'amount': amount,
      'status': status,
      'date': date,
      'time': time,
      'paymentMethod': paymentMethod,
      'orderId': orderId,
      'description': description,
    };
  }

  // Convert Firestore snapshot to TransactionRecord object
  factory TransactionsRecord.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return TransactionsRecord(
      id: snapshot.id,
      userId: data['userId'],
      transactionType: data['transactionType'],
      amount: data['amount'].toDouble(),
      status: data['status'],
      date: data['date'],
      time: data['time'],
      paymentMethod: data['paymentMethod'],
      orderId: data['orderId'],
      description: data['description'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        transactionType,
        amount,
        status,
        date,
        time,
        paymentMethod,
        orderId,
        description,
      ];
}
