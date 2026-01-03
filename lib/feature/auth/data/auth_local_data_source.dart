import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/feature/auth/data/models/userModel.dart';
import 'package:shop_app/core/enums/user_type.dart';

class AuthLocalDataSource {
  static const String _userKey = 'cached_user';

  // ========================================
  // ✅ SAVE USER
  // ========================================
  Future<void> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save as JSON string
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);
      
      // Also save individual fields for backwards compatibility
      await Prefs.setString('id', user.id);
      await Prefs.setString('name', user.name);
      await Prefs.setString('email', user.email);
      await Prefs.setString('phone', user.phone);
      await Prefs.setString('image', user.image);
      await Prefs.setString('user_type', user.userType.value);
      
      print('✅ User saved to local storage: ${user.email}');
    } catch (e) {
      print('❌ Error saving user: $e');
      rethrow;
    }
  }

  // ========================================
  // ✅ GET USER
  // ========================================
  Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try to get the full user JSON first
      final userJsonString = prefs.getString(_userKey);
      
      if (userJsonString != null) {
        final userJson = jsonDecode(userJsonString) as Map<String, dynamic>;
        return UserModel.fromJson(userJson);
      }
      
      // Fallback: Try to construct from individual fields
      final id = prefs.getString('id');
      final name = prefs.getString('name');
      final email = prefs.getString('email');
      
      if (id != null && name != null && email != null) {
        return UserModel(
          id: id,
          name: name,
          email: email,
          phone: prefs.getString('phone') ?? '',
          image: prefs.getString('image') ?? '',
          userType: UserType.fromString(
            prefs.getString('user_type') ?? 'customer',
          ),
        );
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }

  // ========================================
  // ✅ CLEAR USER
  // ========================================
  Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove all user-related keys
      await prefs.remove(_userKey);
      await prefs.remove('id');
      await prefs.remove('name');
      await prefs.remove('email');
      await prefs.remove('phone');
      await prefs.remove('image');
      await prefs.remove('user_type');
      
      print('✅ User data cleared from local storage');
    } catch (e) {
      print('❌ Error clearing user: $e');
      rethrow;
    }
  }

  // ========================================
  // ✅ CHECK IF USER EXISTS
  // ========================================
  Future<bool> hasUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_userKey) || prefs.containsKey('id');
    } catch (e) {
      print('❌ Error checking user: $e');
      return false;
    }
  }
}