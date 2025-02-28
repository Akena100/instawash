part of 'package_repo.dart';

abstract class BasePackagesRepository {
  Stream<List<Service>> getAllPackages();

  Stream<List<Service>> getPackagesByName(String name);
}
