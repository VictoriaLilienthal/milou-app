import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:milou_app/dog_breeds.dart';

import 'configs.dart';

class DogProfilePage extends StatefulWidget {
  const DogProfilePage({Key? key}) : super(key: key);

  @override
  DogProfilePageState createState() => DogProfilePageState();
}

class DogProfilePageState extends State<DogProfilePage> {
  TextEditingController textFieldController = TextEditingController();
  String breed = "Kooikerhondje";
  String age = "";
  int birthday = 0;

  @override
  Widget build(BuildContext context) {
    const String assetName = 'images/svg.svg';
    final Widget svg = SvgPicture.asset(assetName, semanticsLabel: 'Dog');

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
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 48,
                child: svg,
              ),
              SizedBox(
                  width: 250,
                  child: TextField(
                    controller: textFieldController,
                    decoration: const InputDecoration(hintText: "Dog Name"),
                  )),
              SizedBox(
                  width: 250,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(age),
                        IconButton(
                            onPressed: () {
                              Future<DateTime?> f = showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2000),
                                  initialDate: DateTime.now(),
                                  lastDate: DateTime.now());

                              f.then((value) {
                                birthday = value!.millisecondsSinceEpoch;
                                Duration d = DateTime.now().difference(value);
                                int days = d.inDays;
                                int years = 0;
                                if (days > 365) {
                                  years = (days ~/ 365);
                                  days %= 365;
                                }
                                int months = 0;
                                if (days > 30) {
                                  months = (days ~/ 30);
                                  days %= 30;
                                }
                                if (years == 0 && months == 0) {
                                  age = "${d.inDays} days";
                                } else if (years == 0 &&
                                    months > 0 &&
                                    days > 0) {
                                  age = "$months months $days days";
                                } else if (years == 0 && months > 0) {
                                  age = "$months months";
                                } else if (years > 0 && months > 0) {
                                  age = "$years years $months months";
                                } else if (years > 0 && months == 0) {
                                  age = "$years years";
                                }

                                setState(() {});
                              });
                            },
                            icon: const Icon(Icons.calendar_month))
                      ])),
              DropdownButton<String>(
                value: breed,
                onChanged: (String? newValue) {
                  setState(() {
                    breed = newValue!;
                  });
                },
                items: dog_breeds
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Unimplemented')))
                    },
                    icon: const Icon(Icons.check),
                    color: Colors.green,
                  ),
                  IconButton(
                    onPressed: () => {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Unimplemented')))
                    },
                    icon: const Icon(Icons.cancel),
                    color: Colors.red,
                  )
                ],
              )
            ],
          ),
        ));
  }
}
