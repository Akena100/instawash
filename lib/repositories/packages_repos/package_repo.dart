import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instawash/models/service.dart';

part 'base_packages_repo.dart';

class PackagesRepos extends BasePackagesRepository {
  final FirebaseFirestore _firebaseFirestore;

  PackagesRepos({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Service>> getAllPackages() {
    return _firebaseFirestore
        .collection('products')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Service.fromSnapshot(doc);
      }).toList();
    });
  }

  @override
  Stream<List<Service>> getPackagesByName(String name) {
    return _firebaseFirestore
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: name)
        .where('name', isLessThan: '${name}z')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Service.fromSnapshot(doc);
      }).toList();
    });
  }
}
