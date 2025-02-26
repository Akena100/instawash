import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications {
  final String id;
  final String userId; // New field to store the user ID
  final String title;
  final String message;
  final DateTime notificationDate;
  final String? imageUrl;
  bool read;

  Notifications({
    required this.id,
    required this.userId, // Adding userId in the constructor
    required this.title,
    required this.message,
    required this.notificationDate,
    this.imageUrl,
    this.read = false, // Default value for 'read' is false
  });

  // To convert Firestore document data to Notification object
  factory Notifications.fromFirestore(Map<String, dynamic> data) {
    return Notifications(
      id: data['id'] ?? '', // Firestore document ID can be used as id
      userId:
          data['userId'] ?? '', // Fetch the userId from the Firestore document
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      notificationDate: (data['notificationDate'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      read: data['read'] ?? false, // Adding the 'read' field
    );
  }

  // To convert Notification object to Map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId, // Storing the userId in the map
      'title': title,
      'message': message,
      'notificationDate': notificationDate,
      'imageUrl': imageUrl,
      'read': read, // Saving the 'read' status
    };
  }
}
