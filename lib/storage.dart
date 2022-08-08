import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

class Storage {
  static late SharedPreferences sh;

  static void init() async {
    sh = await SharedPreferences.getInstance();
  }

  static bool has(String key) {
    return sh.containsKey('data');
  }

  static String? get(String key) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser != null){
      String uid = currentUser.uid;
      DatabaseReference ref = FirebaseDatabase.instance.ref(uid);
      ref.get();
    }

    return sh.getString('data');
  }

  static Future<bool> store(String key, String val) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser != null){
      String uid = currentUser.uid;
      DatabaseReference ref = FirebaseDatabase.instance.ref(uid);
      await ref.set(val);
    }
    return sh.setString('data', val);
  }
}
