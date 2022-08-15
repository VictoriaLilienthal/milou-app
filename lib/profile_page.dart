import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import 'main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const providerConfigs = [EmailProviderConfiguration()];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Milou"),
      ),
      body: ProfileScreen(
        providerConfigs: providerConfigs,
        actions: [
          SignedOutAction((context) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LandingApp()));
          }),
        ],
      ),
    );
  }
}
