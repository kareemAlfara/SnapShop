import 'package:shop_app/feature/checkout/domain/entities/order_entity.dart';
import 'package:shop_app/feature/mainview/domain/entities/cartEntity.dart';

abstract class OrderRepository {
  Future<String?> createOrder({
    required OrderEntity order,
    required List<CartEntity> cartItems,
  });

  Future<List<OrderEntity>> getUserOrders(String userId);

  Future<OrderEntity?> getOrderById(String orderId);

  Future<bool> updateOrderStatus(String orderId, String status);

  Future<bool> cancelOrder(String orderId);
}

