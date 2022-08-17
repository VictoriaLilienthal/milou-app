import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterfire_ui/auth.dart';

import 'firebase_options.dart';
import 'home.dart';

class LandingApp extends StatelessWidget {
  const LandingApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Configure types of login we provide, currently just email
    const providerConfigs = [
      EmailProviderConfiguration(),
    ];

    // This is the main app.
    return MaterialApp(
        darkTheme: ThemeData(
            brightness: Brightness.dark,
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xff004e54))),
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

class LandingAppWithTheme extends StatelessWidget {
  final ThemeData themeDark;
  final ThemeData themeLight;
  const LandingAppWithTheme(
    this.themeLight,
    this.themeDark, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Configure types of login we provide, currently just email
    const providerConfigs = [
      EmailProviderConfiguration(),
    ];

    // This is the main app.
    return MaterialApp(
        darkTheme: themeDark,
        theme: themeLight,
        themeMode: ThemeMode.light,
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
  // Connect to firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // if running locally, connect to local firebase instances for quicker development
  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  // WidgetsFlutterBinding.ensureInitialized();

  // try {
  //   final themeStr =
  //       await rootBundle.loadString('theme/appainter_theme_dark.json');
  //   final themeJson = jsonDecode(themeStr);
  //   final themeDark = ThemeDecoder.decodeThemeData(themeJson)!;

  //   final themeStr2 =
  //       await rootBundle.loadString('theme/appainter_theme_light.json');
  //   final themeJson2 = jsonDecode(themeStr);
  //   final themeLight = ThemeDecoder.decodeThemeData(themeJson)!;

  //   runApp(LandingAppWithTheme(themeLight, themeDark));
  // } catch (e) {
  //   runApp(const LandingApp());
  // }

  runApp(const LandingApp());
}
