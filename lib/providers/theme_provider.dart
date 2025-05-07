import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isThemeDark = prefs.getBool(themeKey) ?? false;
    _themeMode = isThemeDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themeKey, isDarkMode);

    notifyListeners();
  }
}
