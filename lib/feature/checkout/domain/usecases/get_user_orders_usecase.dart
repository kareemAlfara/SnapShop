
import 'package:shop_app/feature/checkout/domain/entities/order_entity.dart';
import 'package:shop_app/feature/checkout/domain/order_repo/order_repository.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';

class GetUserOrdersUseCase {
  final OrderRepository repository;

  GetUserOrdersUseCase(this.repository);

  // ✅ جلب طلبات المستخدم
  Future<List<OrderEntity>> call({String? userId}) async {
    try {
      // إذا لم يتم تمرير userId، نحصل عليه من SharedPreferences
      final String? currentUserId = userId ?? Prefs.getString("id");

      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('User not logged in');
      }

      return await repository.getUserOrders(currentUserId);
    } catch (e) {
      print("❌ Error in GetUserOrdersUseCase: $e");
      rethrow;
    }
  }
}