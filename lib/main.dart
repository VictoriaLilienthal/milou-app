import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutterfire_ui/auth.dart';

import 'home.dart';
import 'storage.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const providerConfigs = [EmailProviderConfiguration()];

    return MaterialApp(
      title: 'Milou App',
      home: SignInScreen(
        providerConfigs: providerConfigs,
        actions: [
          AuthStateChangeAction<SignedIn>((context, state) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeApp()));
          }),
        ],
      ),
    );
  }
}

void main() async {
  Storage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseDatabase.instance.databaseURL =
        "http://localhost:9000/?ns=milou-4b168";
  } else {
    FirebaseDatabase.instance.databaseURL =
        "https://milou-4b168-default-rtdb.firebaseio.com/";
  }
  runApp(const MyApp());
}
//
// ProfileScreen(
// providerConfigs: providerConfigs,
// actions: [
// SignedOutAction((context) {
// Navigator.of(context).pushReplacement(
// MaterialPageRoute(builder: (context) => const SignInScreen(providerConfigs: providerConfigs)));
// }),
// ],
// )