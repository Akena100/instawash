import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class More extends Equatable {
  final String id;
  final String name;
  final String imageUrl;

  const More({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  // Convert JSON to More object
  factory More.fromJson(Map<String, dynamic> json) {
    return More(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }

  // Convert More object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  // Convert Firestore snapshot to More object
  factory More.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return More(
      id: snapshot.id,
      name: data['name'],
      imageUrl: data['imageUrl'],
    );
  }

  @override
  List<Object?> get props => [id, name, imageUrl];
}
