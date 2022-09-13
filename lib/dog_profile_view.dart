import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'configs.dart';
import 'data/dog_profile.dart';

class DogProfileView extends StatefulWidget {
  final DogProfile dog;
  const DogProfileView(this.dog, {Key? key}) : super(key: key);

  @override
  DogProfileViewState createState() => DogProfileViewState();
}

class DogProfileViewState extends State<DogProfileView> {
  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    textEditingController.text = widget.dog.dogName;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (s) => {
                if (s == '0')
                  {currentTheme.switchThemes()}
                else if (s == '1')
                  {
                    setState(() {
                      FirebaseAuth.instance.signOut();
                    })
                  }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: "0",
                    child: ListTile(
                      leading: Icon(
                        currentTheme.isDark()
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      title: Text(
                          currentTheme.isDark() ? "Light Mode" : "Dark Mode"),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: "1",
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text("Logout"),
                    ),
                  )
                ];
              },
            ),
          ],
        ),
        body: Column(
          children: [
            TextField(
              readOnly: true,
              controller: textEditingController,
            )
          ],
        ));
  }
}
