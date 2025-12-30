import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Prefs{
  static late SharedPreferences _instance;

  Prefs._internal();

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();

  }

  static Future<void> setBool(String key, bool value) async {
    await _instance.setBool(key, value);
  }
  static bool getBool(String key) {
    return _instance.getBool(key) ?? false;
  }
    static setString(String key, String value) async {
    await _instance.setString(key, value);
  }

  static getString(String key) {
    return _instance.getString(key) ?? "";
  }

  // ✅ String List
  static Future<void> setStringList(String key, List<String> value) async {
    await _instance.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return _instance.getStringList(key);
  }

  // ✅ Remove key
  static Future<void> remove(String key) async {
    await _instance.remove(key);
  }

  // ✅ Clear all (optional)
  static Future<void> clear() async {
    await _instance.clear();
  }
}