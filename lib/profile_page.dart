import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import 'main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const providerConfigs = [EmailProviderConfiguration()];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Training"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
        ],
        onTap: (value) {
          if (value == 0) {
            Navigator.of(context).pop();
          }
        },
      ),
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: ProfileScreen(
        providerConfigs: providerConfigs,
        actions: [
          SignedOutAction((context) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LandingApp()));
          }),
        ],
      ),
    );
  }
}
