import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/feature/auth/data/models/userModel.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';

class AuthLocalDataSource {
  Future<void> saveUser(Usermodel user) async {
    // final prefs = await SharedPreferences.getInstance();
    Prefs.setString('name', user.name);
    Prefs.setString("id", user.id);
    Prefs.setString("name", user.name);
  }
   Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
