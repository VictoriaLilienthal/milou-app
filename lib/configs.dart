library config.globals;

import 'package:shared_preferences/shared_preferences.dart';

import 'theme_data.dart';

Preferences pref = Preferences();

ThemeProvider currentTheme = ThemeProvider();

class Preferences {
  static late SharedPreferences prefs;

  bool get(String key) {
    if (!prefs.containsKey(key)) {
      return false;
    }
    return prefs.getBool(key)!;
  }

  void set(String key, bool val) {
    prefs.setBool(key, val);
  }

  static init() async {
    prefs = await SharedPreferences.getInstance();
  }
}
