import 'package:shop_app/feature/checkout/domain/entities/order_entity.dart';
import 'package:shop_app/feature/mainview/domain/entities/cartEntity.dart';

import '../order_repo/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<String?> call({
    required OrderEntity order,
    required List<CartEntity> cartItems,
  }) async {
    return await repository.createOrder(
      order: order,
      cartItems: cartItems,
    );
  }
}