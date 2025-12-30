import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }
  bool get isDark => value == ThemeMode.dark; 
  void toggleTheme() async {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', value == ThemeMode.dark,);

  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final isDark = prefs.getBool('isDark') ?? false;
    value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
