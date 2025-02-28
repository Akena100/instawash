import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/user_model.dart';

part 'base_user_repo.dart';

class UserRepository extends BaseUserRepository {
  final FirebaseFirestore _firebaseFirestore;

  UserRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Stream<UserModel> getUser(String userId) {
    return _firebaseFirestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snap) => UserModel.fromSnapshot(snap));
  }
}
