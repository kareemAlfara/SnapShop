import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/feature/checkout/domain/entities/order_entity.dart';
import 'package:shop_app/feature/checkout/domain/usecases/create_order_usecase.dart';
import 'package:shop_app/feature/checkout/domain/usecases/get_user_orders_usecase.dart';
import 'package:shop_app/feature/mainview/domain/entities/cartEntity.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final GetUserOrdersUseCase getUserOrdersUseCase;

  OrderCubit({
    required this.createOrderUseCase,
    required this.getUserOrdersUseCase,
  }) : super(OrderInitial());

  static OrderCubit get(context) => BlocProvider.of(context);

  Future<void> createOrder({
    required OrderEntity order,
    required List<CartEntity> cartItems,
  }) async {
    emit(OrderLoading());

    try {
      final orderId = await createOrderUseCase(
        order: order,
        cartItems: cartItems,
      );

      if (orderId != null) {
        emit(OrderSuccess(orderId));
      } else {
        emit(const OrderFailure('Failed to create order'));
      }
    } catch (e) {
      emit(OrderFailure(e.toString()));
    }
  }

  Future<void> getUserOrders() async {
    emit(OrderLoading());

    try {
      final orders = await getUserOrdersUseCase();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderFailure(e.toString()));
    }
  }
}