import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String profilePictureUrl; // URL for the profile picture

  UserProfile({
    required this.userId,
    required this.profilePictureUrl,
  });

  // Convert JSON to UserProfile object
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      profilePictureUrl:
          json['profilePictureUrl'] ?? '', // Default to empty string if null
    );
  }

  // Convert UserProfile object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  // Convert Firestore snapshot to UserProfile object
  factory UserProfile.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return UserProfile(
      userId: data['userId'],
      profilePictureUrl:
          data['profilePictureUrl'] ?? '', // Default to empty string if null
    );
  }
}
