// Cubit
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instawash/models/service.dart';
import 'package:instawash/repositories/favourite_packages_repo/fav_packages_repo.dart';

import 'package:instawash/repositories/repositories.dart';

part 'fav_packages_state.dart';

class FavouritePackagesCubit extends Cubit<FavoritesPackagesState> {
  final BaseFavoritePackagesRepository _repository;
  StreamSubscription? _streamSubscription;

  FavouritePackagesCubit(this._repository) : super(FavoritePackagesInitial());

  Future<void> loadFavorites(String userId) async {
    try {
      _streamSubscription?.cancel();
      _streamSubscription = _repository.getFavoritePackages(userId).listen(
        (packages) {
          emit(
            FavoritePackagesLoaded(packages),
          );
        },
      );
    } catch (e) {
      emit(FavoritePackagesError('Error loading favorite packages: $e'));
    }
  }

  void toggleFavorite(String userId, Service service) async {
    final isFavorite = await _repository.isPackageFavorite(userId, service.id);

    if (isFavorite) {
      await _repository.removeFavoritePackage(userId, service.id);
    } else {
      await _repository.addFavoritePackage(userId, service);
    }

    loadFavorites(userId);
  }
}
