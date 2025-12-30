import 'dart:convert';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/feature/mainview/data/models/ProductModel.dart';

class RecentProductsHelper {
  static const String _key = 'recent_products';

  /// 🔹 إضافة منتج إلى قائمة "شوهد مؤخرًا"
  static Future<void> addProduct(Productmodel product) async {
    List<String> current = Prefs.getStringList(_key) ?? [];

    // حوّل المنتج إلى JSON
    String jsonProduct = jsonEncode(product.tojson());

    // لو المنتج موجود بالفعل نحذفه قبل ما نضيفه في البداية
    current.removeWhere((p) {
      var decoded = jsonDecode(p);
      return decoded['id'] == product.id;
    });

    // نضيفه في أول القائمة
    current.insert(0, jsonProduct);

    // نحتفظ بآخر 10 فقط
    if (current.length > 10) current = current.sublist(0, 10);

    await Prefs.setStringList(_key, current);
  }

  /// 🔹 استرجاع المنتجات التي شوهدت مؤخرًا
  static List<Productmodel> getRecentProducts() {
    List<String> stored = Prefs.getStringList(_key) ?? [];
    return stored
        .map((jsonStr) => Productmodel.Fromjson(jsonDecode(jsonStr)))
        .toList();
  }

  /// 🔹 حذف القائمة بالكامل
  static Future<void> clearRecent() async {
    await Prefs.remove(_key);
  }
}
