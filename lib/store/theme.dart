import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider() {
    x();
  }

  void x() async {
    final prefs = await SharedPreferences.getInstance();

    String currentTheme = prefs.getString('theme') ?? 'light';

    _themeMode = currentTheme == 'light' ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;

  void changeTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
