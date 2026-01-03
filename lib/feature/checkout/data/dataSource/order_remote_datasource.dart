// ========================================
// 📁 lib/feature/checkout/data/datasources/order_remote_data_source.dart
// ========================================
import 'dart:developer';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/feature/checkout/data/models/OrderModel.dart';
import 'package:shop_app/feature/checkout/data/models/order_item_model.dart';
import 'package:shop_app/feature/mainview/domain/entities/cartEntity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OrderRemoteDataSource {
  Future<String?> createOrder({
    required OrderModel order,
    required List<CartEntity> cartItems,
  });
  Future<List<OrderModel>> getUserOrders(String userId);
  Future<OrderModel?> getOrderById(String orderId);
  Future<List<OrderItemModel>> getOrderItems(String orderId);
  Future<int> getOrderItemsCount(String orderId);
  Future<bool> updateOrderStatus(String orderId, String status);
  Future<bool> cancelOrder(String orderId);
  Future<bool> assignDeliveryPerson(String orderId, String deliveryPersonId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final SupabaseClient supabase;

  OrderRemoteDataSourceImpl({required this.supabase});

  @override
  Future<String?> createOrder({
    required OrderModel order,
    required List<CartEntity> cartItems,
  }) async {
    try {
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      log('🚀 CREATING ORDER IN DATABASE');
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      // ✅ Log order data before sending
      log('📋 Order Details:');
      log('   User ID: ${order.userId}');
      log('   Total Amount: \$${order.totalAmount}');
      log('   Final Amount: \$${order.finalAmount}');
      log('   Delivery Method: ${order.deliveryMethod}');
      log('   Payment Method: ${order.paymentMethod}');
      log('   Payment Status: ${order.paymentStatus}');
      log('   Cart Items: ${cartItems.length}');
      
      // 1. ✅ Create the order
      log('\n📤 Step 1: Inserting order into orders table...');
      final orderResponse = await supabase
          .from('orders')
          .insert(order.toJson())
          .select('id')
          .single();

      final orderId = orderResponse['id'] as String;
      log('✅ Order created with ID: $orderId');

      // 2. ✅ Prepare order items
      if (cartItems.isEmpty) {
        log('⚠️ WARNING: No cart items to add!');
        return orderId;
      }

      log('\n📦 Step 2: Preparing ${cartItems.length} order items...');
      final List<Map<String, dynamic>> orderItemsJson = [];
      
      for (int i = 0; i < cartItems.length; i++) {
        final cart = cartItems[i];
        final subtotal = cart.product.price * cart.quantity;
        
        final itemJson = OrderItemModel(
          orderId: orderId, // ✅ Use the returned order ID
          productId: cart.product.id,
          productTitle: cart.product.title,
          productImage: cart.product.image,
          price: cart.product.price,
          quantity: cart.quantity,
          subtotal: subtotal,
        ).toJson();
        
        orderItemsJson.add(itemJson);
        
        log('   Item ${i + 1}:');
        log('      Product: ${cart.product.title}');
        log('      Quantity: ${cart.quantity}');
        log('      Price: \$${cart.product.price}');
        log('      Subtotal: \$${subtotal}');
      }

      // 3. ✅ Insert order items
      log('\n📤 Step 3: Inserting ${orderItemsJson.length} items into order_items table...');
      final itemsResponse = await supabase
          .from('order_items')
          .insert(orderItemsJson)
          .select();
      
      log('✅ Order items saved successfully');
      log('✅ Inserted ${(itemsResponse as List).length} items');

      // 4. ✅ Verify insertion
      log('\n🔍 Step 4: Verifying order items...');
      final verifyItems = await supabase
          .from('order_items')
          .select()
          .eq('order_id', orderId);
      
      final itemCount = (verifyItems as List).length;
      log('✅ Verification: Found $itemCount items for order $orderId');

      if (itemCount != cartItems.length) {
        log('⚠️ WARNING: Mismatch in item count!');
        log('   Expected: ${cartItems.length}');
        log('   Found: $itemCount');
      }

      log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      log('✅ ORDER CREATION COMPLETED SUCCESSFULLY');
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return orderId;
      
    } on PostgrestException catch (e) {
      log('\n❌━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      log('❌ SUPABASE ERROR');
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      log('Error Message: ${e.message}');
      log('Error Code: ${e.code}');
      log('Error Details: ${e.details}');
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    } catch (e, stackTrace) {
      log('\n❌━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      log('❌ UNEXPECTED ERROR');
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      log('Error: $e');
      log('Stack Trace: $stackTrace');
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      log('📥 Fetching orders for user: $userId');

      final response = await supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final orders = (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();

      log('✅ Loaded ${orders.length} orders from database');
      
      return orders;
    } on PostgrestException catch (e) {
      log('❌ Supabase Error fetching orders: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ Error fetching orders: $e');
      rethrow;
    }
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      log('📥 Fetching order: $orderId');
      
      final response = await supabase
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();

      final order = OrderModel.fromJson(response);
      log('✅ Order loaded: ${order.id}');
      
      return order;
    } on PostgrestException catch (e) {
      log('❌ Supabase Error fetching order: ${e.message}');
      return null;
    } catch (e) {
      log('❌ Error fetching order by ID: $e');
      return null;
    }
  }

  @override
  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    try {
      log('📥 Fetching items for order: $orderId');
      
      final response = await supabase
          .from('order_items')
          .select()
          .eq('order_id', orderId);

      log('📥 Raw response: $response');
      
      final items = (response as List)
          .map((json) {
            log('📦 Parsing item: $json');
            return OrderItemModel.fromJson(json);
          })
          .toList();

      log('✅ Loaded ${items.length} order items');
      
      return items;
    } on PostgrestException catch (e) {
      log('❌ Supabase Error fetching order items: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      log('❌ Error fetching order items: $e');
      log('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<int> getOrderItemsCount(String orderId) async {
    try {
      final response = await supabase
          .from('order_items')
          .select()
          .eq('order_id', orderId);

      return (response as List).length;
    } on PostgrestException catch (e) {
      log('❌ Supabase Error checking order items count: ${e.message}');
      return 0;
    } catch (e) {
      log('❌ Error checking order items count: $e');
      return 0;
    }
  }

  @override
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      log('🔄 Updating order $orderId status to: $status');
      
      await supabase.from('orders').update({
        'order_status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      log('✅ Order status updated successfully');
      return true;
    } on PostgrestException catch (e) {
      log('❌ Supabase Error updating order status: ${e.message}');
      return false;
    } catch (e) {
      log('❌ Error updating order status: $e');
      return false;
    }
  }

  @override
  Future<bool> cancelOrder(String orderId) async {
    try {
      log('❌ Cancelling order: $orderId');
      
      await supabase.from('orders').update({
        'order_status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      log('✅ Order cancelled successfully');
      return true;
    } on PostgrestException catch (e) {
      log('❌ Supabase Error cancelling order: ${e.message}');
      return false;
    } catch (e) {
      log('❌ Error cancelling order: $e');
      return false;
    }
  }

  @override
  Future<bool> assignDeliveryPerson(
    String orderId,
    String deliveryPersonId,
  ) async {
    try {
      log('🚚 Assigning delivery person $deliveryPersonId to order $orderId');
      
      await supabase.from('orders').update({
        'delivery_person_id': deliveryPersonId,
        'order_status': 'shipping',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      log('✅ Delivery person assigned successfully');
      return true;
    } on PostgrestException catch (e) {
      log('❌ Supabase Error assigning delivery person: ${e.message}');
      return false;
    } catch (e) {
      log('❌ Error assigning delivery person: $e');
      return false;
    }
  }
}