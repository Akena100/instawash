import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instawash/models/order.dart';
import 'package:instawash/repositories/repositories.dart';

part 'place_order_state.dart';

class PlaceOrderCubit extends Cubit<PlaceOrderState> {
  final BaseOrdersRepository ordersRepository;

  PlaceOrderCubit({required this.ordersRepository})
      : super(PlaceOrderInitial());

  Future<void> placeOrder(OrderModel orderModel) async {
    emit(PlaceOrderLoading());
    try {
      await ordersRepository.placeOrder(orderModel);
      emit(OrderPlacedSuccessfully());
    } catch (e) {
      emit(const PlaceOrderError(errorMessage: 'Failed to place booking'));
    }
  }
}
