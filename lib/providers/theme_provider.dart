import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _themeColorKey = 'theme_color';

  bool _isDarkMode = false;
  String _themeColor = 'blue';

  bool get isDarkMode => _isDarkMode;
  String get themeColor => _themeColor;

  ThemeData get currentTheme => AppTheme.getTheme(_themeColor, _isDarkMode);

  ThemeProvider() {
    _loadThemePreferences();
  }

  Future<void> _loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    _themeColor = prefs.getString(_themeColorKey) ?? 'blue';
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setThemeColor(String color) async {
    _themeColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeColorKey, color);
    notifyListeners();
  }

  // Get theme mode for MaterialApp
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
}