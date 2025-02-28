part of 'filter_cubit.dart';

abstract class FilterState extends Equatable {
  const FilterState();

  @override
  List<Object> get props => [];
}

class FilterInitial extends FilterState {}

class FilterLoading extends FilterState {}

class FilterSuccess extends FilterState {
  final List<MealModel> filteredMeals;

  const FilterSuccess(this.filteredMeals);

  @override
  List<Object> get props => [filteredMeals];
}

class FilterError extends FilterState {
  final String errorMessage;

  const FilterError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
