import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import 'main.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text('Milou'),
        ),
        ListTile(
          title: const Text('Profile'),
          onTap: () {
            const providerConfigs = [EmailProviderConfiguration()];
            ProfileScreen profileScreen = ProfileScreen(
              providerConfigs: providerConfigs,
              actions: [
                SignedOutAction((context) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const LandingApp()));
                }),
              ],
            );
            Navigator.of(context).pop();
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => profileScreen));
          },
        ),
      ],
    ));
  }
}
