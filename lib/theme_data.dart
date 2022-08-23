import 'package:flutter/material.dart';

import 'configs.dart';

class ThemeProvider with ChangeNotifier {
  static bool _isDark = pref.get("dark_mode");

  ThemeMode getDarkMode() {
    return _isDark ? ThemeMode.dark : ThemeMode.light;
  }

  bool isDark() {
    return _isDark;
  }

  void switchThemes() {
    _isDark = !_isDark;
    notifyListeners();
    pref.set("dark_mode", _isDark);
  }
}
