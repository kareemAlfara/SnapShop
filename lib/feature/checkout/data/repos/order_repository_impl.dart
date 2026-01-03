// ========================================
// 📁 lib/feature/checkout/data/repos/order_repository_impl.dart
// ========================================
import 'package:shop_app/feature/checkout/data/dataSource/order_remote_datasource.dart';
import 'package:shop_app/feature/checkout/data/models/OrderModel.dart';
import 'package:shop_app/feature/checkout/domain/entities/order_entity.dart';
import 'package:shop_app/feature/checkout/domain/order_repo/order_repository.dart';
import 'package:shop_app/feature/mainview/domain/entities/cartEntity.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String?> createOrder({
    required OrderEntity order,
    required List<CartEntity> cartItems,
  }) async {
    try {
      // ✅ Validation
      if (order.userId.isEmpty) {
        throw Exception('User ID is required for creating order');
      }

      if (cartItems.isEmpty) {
        throw Exception('Cart items cannot be empty');
      }

      // ✅ Convert Entity to Model
      final orderModel = OrderModel.fromEntity(order);

      // ✅ Call data source
      final orderId = await remoteDataSource.createOrder(
        order: orderModel,
        cartItems: cartItems,
      );

      return orderId;
    } catch (e) {
      print('❌ Repository Error creating order: $e');
      rethrow;
    }
  }

  @override
  Future<List<OrderEntity>> getUserOrders(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID is required');
      }

      // ✅ Call data source
      final orderModels = await remoteDataSource.getUserOrders(userId);

      // ✅ Convert Models to Entities
      final orders = orderModels.map((model) => model.toEntity()).toList();

      return orders;
    } catch (e) {
      print('❌ Repository Error fetching user orders: $e');
      rethrow;
    }
  }

  @override
  Future<OrderEntity?> getOrderById(String orderId) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('Order ID is required');
      }

      // ✅ Call data source
      final orderModel = await remoteDataSource.getOrderById(orderId);

      if (orderModel == null) {
        return null;
      }

      // ✅ Convert Model to Entity
      return orderModel.toEntity();
    } catch (e) {
      print('❌ Repository Error fetching order: $e');
      return null;
    }
  }

  @override
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('Order ID is required');
      }

      if (status.isEmpty) {
        throw Exception('Status is required');
      }

      // ✅ Call data source
      return await remoteDataSource.updateOrderStatus(orderId, status);
    } catch (e) {
      print('❌ Repository Error updating order status: $e');
      return false;
    }
  }

  @override
  Future<bool> cancelOrder(String orderId) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('Order ID is required');
      }

      // ✅ Call data source
      return await remoteDataSource.cancelOrder(orderId);
    } catch (e) {
      print('❌ Repository Error cancelling order: $e');
      return false;
    }
  }

  // ✅ Additional method for assigning delivery person
  Future<bool> assignDeliveryPerson(
    String orderId,
    String deliveryPersonId,
  ) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('Order ID is required');
      }

      if (deliveryPersonId.isEmpty) {
        throw Exception('Delivery person ID is required');
      }

      // ✅ Call data source
      return await remoteDataSource.assignDeliveryPerson(
        orderId,
        deliveryPersonId,
      );
    } catch (e) {
      print('❌ Repository Error assigning delivery person: $e');
      return false;
    }
  }

  // ✅ Additional method to get order items
  Future<int> getOrderItemsCount(String orderId) async {
    try {
      if (orderId.isEmpty) {
        return 0;
      }

      return await remoteDataSource.getOrderItemsCount(orderId);
    } catch (e) {
      print('❌ Repository Error getting order items count: $e');
      return 0;
    }
  }
}