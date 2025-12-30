import 'package:shop_app/feature/checkout/data/datasource/order_remote_datasource.dart';
import 'package:shop_app/feature/checkout/data/models/OrderModel.dart';
import 'package:shop_app/feature/checkout/domain/entities/order_entity.dart';
import 'package:shop_app/feature/checkout/domain/entities/order_item_entity.dart';
import 'package:shop_app/feature/checkout/domain/order_repo/order_repository.dart';
import 'package:shop_app/feature/mainview/domain/entities/cartEntity.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<String?> createOrder({
    required OrderEntity order,
    required List<CartEntity> cartItems,
  }) async {
    try {
      // تحويل Entity إلى Model
      final orderModel = OrderModel(
        id: order.id,
        userId: order.userId,
        totalAmount: order.totalAmount,
        deliveryFee: order.deliveryFee,
        finalAmount: order.finalAmount,
        deliveryMethod: order.deliveryMethod,
        deliveryTime: order.deliveryTime,
        paymentMethod: order.paymentMethod,
        orderStatus: order.orderStatus,
        paymentStatus: order.paymentStatus,
        deliveryAddress: order.deliveryAddress,
        notes: order.notes,
        createdAt: order.createdAt,
      );

      return await remoteDataSource.createOrder(
        order: orderModel,
        cartItems: cartItems,
      );
    } catch (e) {
      print('❌ Repository Error: $e');
      return null;
    }
  }

  @override
  Future<List<OrderEntity>> getUserOrders() async {
    try {
      final orders = await remoteDataSource.getUserOrders();
      return orders.map((model) => model.toEntity()).toList();
    } catch (e) {
      print('❌ Repository Error: $e');
      return [];
    }
  }

  @override
  Future<List<OrderItemEntity>> getOrderItems(String orderId) async {
    try {
      final items = await remoteDataSource.getOrderItems(orderId);
      return items.map((model) => model.toEntity()).toList();
    } catch (e) {
      print('❌ Repository Error: $e');
      return [];
    }
  }
}