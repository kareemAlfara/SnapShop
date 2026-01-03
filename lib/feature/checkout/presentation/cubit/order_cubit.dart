import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/feature/auth/data/auth_remote_data_source.dart';
import 'package:shop_app/feature/checkout/domain/entities/order_entity.dart';
import 'package:shop_app/feature/checkout/domain/usecases/create_order_usecase.dart';
import 'package:shop_app/feature/checkout/domain/usecases/get_user_orders_usecase.dart';
import 'package:shop_app/feature/mainview/domain/entities/cartEntity.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final GetUserOrdersUseCase getUserOrdersUseCase;
late final AuthRemoteDataSource authDataSource;

  OrderCubit({
    required this.createOrderUseCase,
    required this.getUserOrdersUseCase,
  }) : super(OrderInitial()){
       authDataSource = getIt<AuthRemoteDataSource>();
  }

  static OrderCubit get(context) => BlocProvider.of(context);

  // ✅ إنشاء طلب جديد مع إشعار
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
        // ✅ إرسال إشعار عند إنشاء الطلب
        await _sendOrderNotification(
          userId: order.userId,
          orderId: orderId,
          status: 'created',
          orderAmount: order.finalAmount.toString(),
        );

        emit(OrderSuccess(orderId));
      } else {
        emit(const OrderFailure('Failed to create order'));
      }
    } catch (e) {
      print("❌ Error creating order: $e");
      emit(OrderFailure(e.toString()));
    }
  }

  // ✅ جلب طلبات المستخدم (محدثة)
  Future<void> getUserOrders([String? userId]) async {
    emit(OrderLoading());
    try {
      // إذا تم تمرير userId استخدمه، وإلا استخدم الـ UseCase الافتراضي
      final orders = await getUserOrdersUseCase(userId: userId);
      
      if (orders.isEmpty) {
        emit(const OrdersEmpty());
      } else {
        emit(OrdersLoaded(orders));
      }
    } catch (e) {
      print("❌ Error fetching user orders: $e");
      emit(OrderFailure(e.toString()));
    }
  }

  // ✅ جلب طلب واحد بالـ ID
  Future<OrderEntity?> getOrderById(String orderId) async {
    try {
      // يمكنك إنشاء UseCase منفصل لهذا أو استخدام الموجود
      final orders = await getUserOrdersUseCase();
      return orders.firstWhere(
        (order) => order.id == orderId,
        orElse: () => throw Exception('Order not found'),
      );
    } catch (e) {
      print("❌ Error fetching order by ID: $e");
      return null;
    }
  }

  // ✅ تحديث حالة الطلب مع إشعار
  Future<void> updateOrderStatus({
    required String orderId,
    required String userId,
    required String status,
    String? estimatedDelivery,
  }) async {
    try {
      // TODO: Update status in database
      // await orderRepository.updateStatus(orderId, status);

      // ✅ إرسال إشعار حسب الحالة
      await _sendOrderNotification(
        userId: userId,
        orderId: orderId,
        status: status,
        estimatedDelivery: estimatedDelivery,
      );

      emit(OrderStatusUpdated());
      
      // ✅ تحديث قائمة الطلبات بعد تحديث الحالة
      await getUserOrders(userId);
    } catch (e) {
      print("❌ Error updating order status: $e");
      emit(OrderFailure(e.toString()));
    }
  }

  // ✅ إلغاء طلب
  Future<void> cancelOrder({
    required String orderId,
    required String userId,
  }) async {
    emit(OrderLoading());
    try {
      // TODO: Cancel order in database
      // await orderRepository.cancelOrder(orderId);

      await _sendOrderNotification(
        userId: userId,
        orderId: orderId,
        status: 'cancelled',
      );

      emit(OrderCancelled());
      
      // ✅ تحديث قائمة الطلبات
      await getUserOrders(userId);
    } catch (e) {
      print("❌ Error cancelling order: $e");
      emit(OrderFailure(e.toString()));
    }
  }

  // ✅ فلترة الطلبات حسب الحالة
  List<OrderEntity> filterOrdersByStatus(
    List<OrderEntity> orders,
    String status,
  ) {
    if (status == 'all') return orders;

    return orders.where((order) {
      switch (status.toLowerCase()) {
        case 'pending':
          return order.orderStatus.toLowerCase() == 'pending' ||
              order.orderStatus.toLowerCase() == 'confirmed' ||
              order.orderStatus.toLowerCase() == 'processing';
        case 'shipping':
          return order.orderStatus.toLowerCase() == 'on the way' ||
              order.orderStatus.toLowerCase() == 'shipping' ||
              order.orderStatus.toLowerCase() == 'packed' ||
              order.orderStatus.toLowerCase() == 'shipped' ||
              order.orderStatus.toLowerCase() == 'out_for_delivery';
        case 'completed':
          return order.orderStatus.toLowerCase() == 'delivered';
        case 'cancelled':
          return order.orderStatus.toLowerCase() == 'cancelled';
        default:
          return false;
      }
    }).toList();
  }

  // ✅ دالة مركزية لإرسال الإشعارات حسب حالة الطلب
  Future<void> _sendOrderNotification({
    required String userId,
    required String orderId,
    required String status,
    String? orderAmount,
    String? estimatedDelivery,
  }) async {
    String title;
    String body;

    switch (status.toLowerCase()) {
      case 'created':
      case 'pending':
        title = "Order Created";
        body = "Your order has been placed successfully";
        break;

      case 'confirmed':
        title = "✅ Order Confirmed";
        body = "Your order #$orderId has been confirmed and is being prepared";
        break;

      case 'processing':
      case 'packed':
        title = "⏳ Order Processing";
        body = "Your order #$orderId is currently being prepared";
        break;

      case 'shipped':
      case 'out_for_delivery':
      case 'on the way':
        title = "📦 Order On The Way";
        body = estimatedDelivery != null
            ? "Your order #$orderId has been shipped and expected to arrive on $estimatedDelivery"
            : "Your order #$orderId has been shipped and will arrive soon";
        break;

      case 'delivered':
        title = "✅ Delivered Successfully";
        body = "Your order #$orderId has arrived! We hope you like it ❤️";
        break;

      case 'cancelled':
        title = "❌ Order Cancelled";
        body = "Your order #$orderId has been cancelled. Refund will be processed in 3-5 days";
        break;

      case 'refunded':
        title = "💰 Refund Processed";
        body = "Amount of \$$orderAmount has been refunded for order #$orderId";
        break;

      case 'failed':
        title = "⚠️ Order Processing Failed";
        body = "There was an issue with order #$orderId. Please contact support";
        break;

      default:
        title = "📢 Order Update";
        body = "Your order #$orderId: $status";
    }

    try {
      await authDataSource.notifyUser(userId, title, body);
      print("✅ Notification sent for order $orderId with status: $status");
    } catch (e) {
      print("❌ Failed to send notification for order $orderId: $e");
      // Don't throw - notification failure shouldn't break the order flow
    }
  }

  // ✅ إرسال إشعار سلة مهجورة
  Future<void> sendAbandonedCartReminder({
    required String userId,
    required int itemsCount,
  }) async {
    try {
      await authDataSource.notifyUser(
        userId,
        "🛒 Don't Forget Your Cart!",
        "You have $itemsCount items waiting for you. Complete your order now!",
      );
      print("✅ Abandoned cart reminder sent to user: $userId");
    } catch (e) {
      print("❌ Failed to send abandoned cart reminder: $e");
    }
  }

  // ✅ إرسال إشعار عرض خاص للمستخدم
  Future<void> sendSpecialOfferNotification({
    required String userId,
    required String offerTitle,
    required String offerDetails,
  }) async {
    try {
      await authDataSource.notifyUser(
        userId,
        "🎉 $offerTitle",
        offerDetails,
      );
      print("✅ Special offer notification sent to user: $userId");
    } catch (e) {
      print("❌ Failed to send special offer notification: $e");
    }
  }

  // ✅ إرسال إشعار جماعي لكل المستخدمين
  Future<void> broadcastNotification({
    required String title,
    required String message,
  }) async {
    try {
      await authDataSource.notifyAllUsers(title, message);
      print("✅ Broadcast notification sent to all users");
    } catch (e) {
      print("❌ Failed to send broadcast notification: $e");
    }
  }

  // ✅ الحصول على عدد الطلبات حسب الحالة
  Map<String, int> getOrdersCountByStatus(List<OrderEntity> orders) {
    return {
      'all': orders.length,
      'pending': filterOrdersByStatus(orders, 'pending').length,
      'shipping': filterOrdersByStatus(orders, 'shipping').length,
      'completed': filterOrdersByStatus(orders, 'completed').length,
      'cancelled': filterOrdersByStatus(orders, 'cancelled').length,
    };
  }

  // ✅ Reset state
  void resetState() {
    emit(OrderInitial());
  }
}