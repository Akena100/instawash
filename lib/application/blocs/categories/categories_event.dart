part of 'categories_bloc.dart';

@immutable
abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends CategoriesEvent {}

class UpdateCategories extends CategoriesEvent {
  final List<MealCategory> categories;

  const UpdateCategories(this.categories);

  @override
  List<Object> get props => [categories];
}
