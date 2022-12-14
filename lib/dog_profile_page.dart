import 'dart:ui';

import 'package:age_calculator/age_calculator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:milou_app/dog_breeds.dart';
import 'package:uuid/uuid.dart';

import 'configs.dart';
import 'data/db.dart';
import 'data/dog_profile.dart';

class DogProfilePage extends StatefulWidget {
  DogProfile? dog;

  DogProfilePage(this.dog, {Key? key}) : super(key: key);

  @override
  DogProfilePageState createState() => DogProfilePageState();
}

class DogProfilePageState extends State<DogProfilePage> {
  TextEditingController textFieldController = TextEditingController();
  String breed = "";
  String age = "";
  int birthday = -1;
  String userAvatarUrl = "";
  DogProfile? d;
  XFile? fileValue;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    d = widget.dog;
    if (d != null) {
      textFieldController.text = d!.dogName;
      age = getBirthdayStr(DateTime.fromMillisecondsSinceEpoch(d!.age));
      birthday = d!.age;
      breed = d!.breed;
      userAvatarUrl = d!.imageUuid;
    }
  }

  @override
  Widget build(BuildContext context) {
    const String assetName = 'images/svg.svg';
    final Widget svg = SvgPicture.asset(assetName, semanticsLabel: 'Dog');

    Widget child = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 48,
                backgroundImage:
                    userAvatarUrl.isEmpty ? null : NetworkImage(userAvatarUrl),
                child: userAvatarUrl.isEmpty ? svg : null,
              ),
              IconButton(
                  onPressed: () {
                    final ImagePicker picker = ImagePicker();
                    picker.pickImage(source: ImageSource.gallery).then((value) {
                      checkSize(value).then((sizeRight) {
                        if (sizeRight) {
                          fileValue = value;
                          setState(() {
                            userAvatarUrl = value!.path;
                          });
                        } else {
                          showSnackBar("Image too big");
                        }
                      });
                    });
                  },
                  icon: const Icon(Icons.upload)),
            ],
          ),
          SizedBox(
              width: 250,
              child: TextField(
                controller: textFieldController,
                onChanged: (v) => {
                  setState(
                    () {},
                  )
                },
                decoration: InputDecoration(
                    hintText: "Dog Name",
                    errorStyle: const TextStyle(),
                    errorText:
                        textFieldController.text.isEmpty ? 'Required' : null),
              )),
          SizedBox(
              width: 250,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      age.isEmpty ? "Required Birthday or Gotcha Day" : age,
                      style: age.isEmpty
                          ? const TextStyle(color: Colors.red)
                          : null,
                    ),
                    IconButton(
                        onPressed: () {
                          Future<DateTime?> f = showDatePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              initialDate: birthday != -1
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                      birthday)
                                  : DateTime.now()
                                      .subtract(const Duration(days: 1)),
                              lastDate: DateTime.now()
                                  .subtract(const Duration(days: 1)));
                          f.then((value) {
                            setState(() {
                              birthday = value!.millisecondsSinceEpoch;
                              age = getBirthdayStr(value);
                            });
                          });
                        },
                        icon: const Icon(Icons.calendar_month))
                  ])),
          SizedBox(
              width: 250,
              child: Autocomplete<String>(
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    onChanged: (v) => setState(() => {}),
                    decoration: InputDecoration(
                        hintText: "Breed",
                        errorStyle: const TextStyle(),
                        errorText: textEditingController.text.isEmpty
                            ? 'Required'
                            : null),
                  );
                },
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return dogBreedsList.where((String option) {
                    return option
                        .toLowerCase()
                        .startsWith(textEditingValue.text.toLowerCase());
                  }).toList();
                },
                initialValue: TextEditingValue(text: breed),
                onSelected: (String selection) {
                  breed = selection;
                },
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  saveDog();
                },
                icon: const Icon(Icons.check),
                color: Colors.green,
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.cancel),
                color: Colors.red,
              )
            ],
          )
        ],
      ),
    );

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
        body: getBody(child));
  }

  String getBirthdayStr(DateTime value) {
    DateDuration duration;
    duration = AgeCalculator.age(value);
    int years = duration.years;
    int months = duration.months;
    int days = duration.days;

    String ret = "";
    if (years > 0) {
      ret += "$years years";
    }
    if (months > 0) {
      ret += " $months months";
    }

    if (days > 0) {
      ret += " $days days";
    }
    return ret;
  }

  Future<String> upload(XFile? value) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userid = currentUser.uid;
      int len = await value!.length();
      if (len / 1000 < 1000) {
        String uid = const Uuid().v4();
        final storageRef =
            FirebaseStorage.instance.ref("user/$userid/dogs/$uid");
        try {
          var data = await value.readAsBytes();
          await storageRef.putData(data);
          uid = await storageRef.getDownloadURL();
          return Future.value(uid);
        } catch (e) {
          return Future.error("Error uploading image");
        }
      }
      return Future.error("Image too large");
    } else {
      throw Exception("User logged out");
    }
  }

  Future<bool> checkSize(XFile? value) async {
    int len = await value!.length();
    if (len / 1000 < 1000) {
      return Future.value(true);
    }
    return Future.value(false);
  }

  void showSnackBar(String e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          e,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1)));
  }

  void saveDog() async {
    if (textFieldController.text.isEmpty) {
      showSnackBar("Name is required");
      return;
    }
    if (breed.isEmpty) {
      showSnackBar("Breed is required");
      return;
    }

    if (birthday == -1) {
      showSnackBar("Age is required");
      return;
    }
    DogProfile dogProfile;
    if (d == null) {
      dogProfile = DogProfile(breed, birthday, textFieldController.text, "",
          DateTime.now().millisecondsSinceEpoch);
    } else {
      dogProfile = d!;
      dogProfile.age = birthday;
      dogProfile.dogName = textFieldController.text;
      dogProfile.breed = breed;
    }

    if (fileValue != null) {
      setState(() {
        _loading = true;
      });

      try {
        dogProfile.imageUuid = await upload(fileValue);
        setState(() {
          _loading = false;
        });
      } catch (e) {
        setState(() {
          _loading = false;
        });
        showSnackBar("Image upload failed");
      }
    }

    setState(() {
      _loading = true;
    });
    DB().addNewDog(dogProfile).then((value) {
      setState(() {
        _loading = false;
      });
      if (d == null) {
        Navigator.of(context).pop(dogProfile);
      } else {
        Navigator.of(context).pop();
      }
    }, onError: (e) {
      setState(() {
        _loading = false;
      });
      showSnackBar(e);
    });
  }

  Widget getBody(Widget child) {
    if (_loading) {
      return Stack(
        children: [
          child,
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.1, sigmaY: 0.1),
            child: const Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.grey),
            ),
          ),
          const Center(
              child: Center(
            child: SpinKitDancingSquare(
              color: Colors.blue,
              size: 50.0,
            ),
          )),
        ],
      );
    } else {
      return child;
    }
  }
}
