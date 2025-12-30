import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/feature/checkout/data/models/OrderModel.dart';
import 'package:shop_app/feature/checkout/data/models/order_item_model.dart';
import 'package:shop_app/feature/mainview/domain/entities/cartEntity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRemoteDataSource {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String?> createOrder({
    required OrderModel order,
    required List<CartEntity> cartItems,
  }) async {
    try {
      // 1. حفظ الطلب الرئيسي
      final orderResponse = await supabase
          .from('orders')
          .insert(order.toJson())
          .select('id')
          .single();

      final orderId = orderResponse['id'] as String;
      print('✅ Order created with ID: $orderId');

      // 2. تحضير تفاصيل الطلب
      final List<Map<String, dynamic>> orderItemsJson = cartItems.map((cart) {
        return OrderItemModel(
          orderId: orderId,
          productId: cart.product.id,
          productTitle: cart.product.title,
          productImage: cart.product.image,
          price: cart.product.price,
          quantity: cart.quantity,
          subtotal: cart.product.price * cart.quantity,
        ).toJson();
      }).toList();

      // 3. حفظ تفاصيل الطلب
      await supabase.from('order_items').insert(orderItemsJson);
      print('✅ Order items saved successfully');

      return orderId;
    } catch (e) {
      print('❌ Error creating order: $e');
      rethrow;
    }
  }

  Future<List<OrderModel>> getUserOrders() async {
    try {
      final userId = Prefs.getString("id");

      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      final response = await supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching orders: $e');
      rethrow;
    }
  }

  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    try {
      final response = await supabase
          .from('order_items')
          .select()
          .eq('order_id', orderId);

      return (response as List)
          .map((json) => OrderItemModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching order items: $e');
      rethrow;
    }
  }
}