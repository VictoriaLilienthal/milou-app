import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'home.dart';
import 'storage.dart';

class LandingApp extends StatelessWidget {
  const LandingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Configure types of login we provide, currently just email
    const providerConfigs = [
      EmailProviderConfiguration(),
    ];

    // This is the main app.
    return MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.dark,
        title: 'Milou',
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          // This part connects to firebase for auth
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            // If we're waiting for connection, show a loading spinner
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: SpinKitDancingSquare(
                color: Colors.blue,
                size: 50.0,
              ));
            }
            final String? uid = snapshot.data?.uid;

            // If user already signed in, log to firebase and take to homepage
            if (uid != null) {
              FirebaseAnalytics.instance.setUserId(id: uid);
              FirebaseAnalytics.instance.logLogin(loginMethod: "email");
              return const HomePageApp();
            } else {
              // If not signed in, go to signup page
              return SignInScreen(
                providerConfigs: providerConfigs,
                actions: [
                  AuthStateChangeAction<SignedIn>((context, state) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const HomePageApp()));
                  }),
                ],
              );
            }
          },
        ));
  }
}

void main() async {
  Storage.init();

  // Connect to firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // if running locally, connect to local firebase instances for quicker development
  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseDatabase.instance.databaseURL =
        "http://localhost:9000/?ns=milou-4b168";
  } else {
    FirebaseDatabase.instance.databaseURL =
        "https://milou-4b168-default-rtdb.firebaseio.com/";
  }

  runApp(const LandingApp());
}
