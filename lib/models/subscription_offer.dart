import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SubscriptionOffer extends Equatable {
  final String id;
  final String serviceId;
  final String subId;
  final String name;

  const SubscriptionOffer({
    required this.id,
    required this.serviceId,
    required this.subId,
    required this.name,
  });

  // Convert JSON to SubscriptionOffer object
  factory SubscriptionOffer.fromJson(Map<String, dynamic> json) {
    return SubscriptionOffer(
      id: json['id'],
      serviceId: json['serviceId'],
      subId: json['subId'],
      name: json['name'],
    );
  }

  // Convert SubscriptionOffer object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'subId': subId,
      'name': name,
    };
  }

  // Convert Firestore snapshot to SubscriptionOffer object
  factory SubscriptionOffer.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return SubscriptionOffer(
      id: snapshot.id,
      serviceId: data['serviceId'],
      subId: data['subId'],
      name: data['name'],
    );
  }

  @override
  List<Object?> get props => [id, serviceId, subId, name];
}
