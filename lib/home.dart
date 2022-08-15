import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:milou_app/goals_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card_widget.dart';
import 'drawer.dart';
import 'mastered_prompt_dialog.dart';
import 'new_command_widgets.dart';
import 'skill.dart';
import 'training_widget.dart';

final prefs = SharedPreferences.getInstance();
const IconData pets = IconData(0xe4a1, fontFamily: 'MaterialIcons');
const Duration secondDuration = Duration(milliseconds: 1000);
const Duration halfSecond = Duration(milliseconds: 500);

// This is a widget for new command window
Widget buildMarkStarredDialog(BuildContext context) {
  return const MasteredPromptDialog();
}

class HomePageApp extends StatefulWidget {
  const HomePageApp({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePageApp> createState() => _HomePageAppState();
}

class _HomePageAppState extends State<HomePageApp> {
  final List<Skill> rowStates = [];
  bool _loading = false;

  DB databaseInstance = DB();

  @override
  void initState() {
    super.initState();

    databaseInstance.pre = () => {
          setState(() => {_loading = true})
        };
    databaseInstance.post = () => {
          setState(() => {_loading = false})
        };

    databaseInstance.getAllSkills().then((value) {
      setState(() {
        rowStates.addAll(value);

        rowStates.sort((a, b) {
          if (a.order < b.order) {
            return -1;
          } else if (a.order > b.order) {
            return 1;
          } else if (a.creationTime > b.creationTime) {
            return -1;
          } else if (a.creationTime < b.creationTime) {
            return 1;
          }
          return 0;
        });

        for (int i = 0; i < rowStates.length; i++) {
          if (!CardWidget.isToday(rowStates[i].lastActivity)) {
            rowStates[i].todayCnt = 0;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Builder(builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Milou"),
              bottom: const TabBar(
                tabs: <Widget>[
                  Tab(
                    text: "Train",
                  ),
                  Tab(
                    text: "Goal",
                  ),
                ],
              ),
            ),
            drawer: const DrawerWidget(),
            body: getBody(TabBarView(
              children: <Widget>[
                TrainingWidget(rowStates),
                const GoalsPage(
                  key: Key("goals-tab"),
                ),
              ],
            )),
            floatingActionButton: FloatingActionButton(
              onPressed: () => {
                if (DefaultTabController.of(context)?.index == 0)
                  {showAddNewCommandDialog()}
                else
                  {addNewGoal()}
              },
              tooltip: 'Add new command',
              child: const Icon(Icons.add),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          );
        }));
  }

  // Show the add new command dialog box
  void showAddNewCommandDialog() async {
    Future<String?> str = showDialog(
        context: context,
        builder: (BuildContext context) =>
            AddNewCommandWidget(isValidSkillName));

    str.then((value) {
      if (value != null && isValidSkillName(value)) {
        Skill s = Skill(value);
        s.creationTime = DateTime.now().millisecondsSinceEpoch;
        databaseInstance.addNewSkill(s).then((value) {
          setState(
            () {
              rowStates.insert(0, s);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('New skill ${s.name} Added'),
                  duration: halfSecond));
            },
          );
        }, onError: (e) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  "Oops, that didn't work as expected. Please try again")));
        });
      }
    });
  }

  void addNewGoal() {}

  bool isValidSkillName(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    for (Skill s in rowStates) {
      if (s.name.toLowerCase() == value.toLowerCase()) {
        return false;
      }
    }
    return true;
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
