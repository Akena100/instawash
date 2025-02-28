part of 'packages_bloc.dart';

@immutable
abstract class PackagesEvent extends Equatable {
  const PackagesEvent();

  @override
  List<Object> get props => [];
}

class LoadPackages extends PackagesEvent {}

class UpdatePackages extends PackagesEvent {
  final List<Service> packages;

  const UpdatePackages(this.packages);

  @override
  List<Object> get props => [packages];
}
