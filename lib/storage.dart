import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class Storage{

  Future<bool> has(String key) {
    return SharedPreferences.getInstance().then((value) => value.containsKey('data'));
  }

  Future<bool> store(String key, String val) {
    return SharedPreferences.getInstance().then((value) => value.setString('data', val));
  }

  Future<String?> get(String key, String val) {
    return SharedPreferences.getInstance().then((value)=> value.getString('data'));
  }

}