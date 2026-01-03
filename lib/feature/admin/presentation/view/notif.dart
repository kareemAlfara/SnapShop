import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/feature/auth/data/auth_remote_data_source.dart';

class NotificationService {
  // final _authDataSource = AuthRemoteDataSource();
    // ✅ استخدم GetIt لجلب AuthRemoteDataSource
  late final AuthRemoteDataSource _authDataSource;
  
  NotificationService() {
    _authDataSource = getIt<AuthRemoteDataSource>();
  }

  // 🛒 إشعار طلب جديد
  Future<void> sendOrderPlacedNotification(String userId, String orderId) async {
    await _authDataSource.notifyUser(
      userId,
      "🛒 تم تأكيد طلبك",
      "طلبك رقم #$orderId تم استلامه وجاري التجهيز",
    );
  }

  // 📦 إشعار شحن الطلب
  Future<void> sendOrderShippedNotification(String userId, String trackingNumber) async {
    await _authDataSource.notifyUser(
      userId,
      "📦 طلبك في الطريق إليك",
      "رقم التتبع: $trackingNumber",
    );
  }

  // 💳 إشعار تأكيد الدفع
  Future<void> sendPaymentConfirmed(String userId, double amount) async {
    await _authDataSource.notifyUser(
      userId,
      "💳 تم تأكيد الدفع",
      "تم استلام مبلغ $amount جنيه بنجاح",
    );
  }

  // 🔥 إشعار عرض جديد (لكل المستخدمين)
  Future<void> sendNewOfferToAll(String offerTitle) async {
    await _authDataSource.notifyAllUsers(
      "🔥 عرض جديد!",
      offerTitle,
    );
  }

  // ⏰ إشعار سلة مهجورة
  Future<void> sendAbandonedCartReminder(String userId, int itemsCount) async {
    await _authDataSource.notifyUser(
      userId,
      "⏰ لا تنسَ سلة التسوق!",
      "لديك $itemsCount منتجات في انتظارك",
    );
  }

  // ✅ إشعار توصيل ناجح
  Future<void> sendDeliverySuccess(String userId, String orderId) async {
    await _authDataSource.notifyUser(
      userId,
      "✅ تم التوصيل بنجاح",
      "طلبك #$orderId وصل! نتمنى أن يعجبك ❤️",
    );
  }

  // ⭐ طلب تقييم المنتج
  Future<void> requestProductReview(String userId, String productName) async {
    await _authDataSource.notifyUser(
      userId,
      "⭐ شاركنا رأيك",
      "كيف كانت تجربتك مع $productName؟",
    );
  }

  // 🎉 إشعار نقاط ولاء
  Future<void> sendLoyaltyPointsEarned(String userId, int points) async {
    await _authDataSource.notifyUser(
      userId,
      "🎉 مبروك!",
      "حصلت على $points نقطة. استخدمها في الشراء القادم!",
    );
  }
}



// ========================================
// 🎯 مثال استخدام في Admin Panel
// ========================================
// class AdminNotificationView extends StatelessWidget {
//   final _notificationService = NotificationService();

//   Future<void> sendFlashSaleNotification() async {
//     await _notificationService.sendNewOfferToAll(
//       "خصم 50% على كل المنتجات لمدة 24 ساعة فقط! ⚡",
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: sendFlashSaleNotification,
//       child: Text("إرسال إشعار عرض جديد 🔥"),
//     );
//   }
// }