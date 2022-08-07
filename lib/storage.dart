import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static late SharedPreferences sh;

  static void init() async {
    sh = await SharedPreferences.getInstance();
  }

  static bool has(String key) {
    return sh.containsKey('data');
  }

  static String? get(String key) {
    return sh.getString('data');
  }

  static Future<bool> store(String key, String val) {
    return sh.setString('data', val);
  }
}
