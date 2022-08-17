import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:milou_app/goals_widget.dart';
import 'package:milou_app/notes_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card_widget.dart';
import 'mastered_prompt_dialog.dart';
import 'new_command_dialog.dart';
import 'new_comment_dialog.dart';
import 'new_goal_dialog.dart';
import 'profile_page.dart';
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
  final List<Goal> goals = [];
  final List<Comment> comments = [];

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

    databaseInstance.getAllGoals().then((value) {
      setState(() {
        goals.addAll(value);
      });
    });

    databaseInstance.getAllComments().then((value) {
      setState(() {
        comments.addAll(value);
        comments.sort(((a, b) => b.creationTime.compareTo(a.creationTime)));
      });
    });

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
        length: 3,
        child: Builder(builder: (BuildContext context) {
          return Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: "Training"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "Profile")
              ],
              onTap: (value) {
                if (value == 1) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ProfilePage()));
                }
              },
            ),
            appBar: AppBar(
              title: const Text("Home"),
              bottom: const TabBar(
                tabs: <Widget>[
                  Tab(
                    text: "Train",
                  ),
                  Tab(
                    text: "Goal",
                  ),
                  Tab(
                    text: "Notes",
                  )
                ],
              ),
            ),
            body: getBody(TabBarView(
              children: <Widget>[
                TrainingWidget(rowStates, goals),
                GoalsWidget(
                  goals,
                  key: const Key("goals-tab"),
                ),
                NotesWidget(comments),
              ],
            )),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                int? index = DefaultTabController.of(context)?.index;
                if (index == 0) {
                  showAddNewCommandDialog();
                } else if (index == 1) {
                  showAddNewGoalDialog();
                } else if (index == 2) {
                  showAddNewCommentDialog();
                }
              },
              tooltip: 'Add new command',
              child: const Icon(Icons.add),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
        }));
  }

  // Show the add new command dialog box
  void showAddNewCommandDialog() async {
    Future<String?> str = showDialog(
      context: context,
      builder: (BuildContext context) => AddNewCommandWidget(
          isValidSkillName, () => {showErrorMessage("Invalid task name")}),
    );

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
      } else {}
    });
  }

  void showAddNewCommentDialog() async {
    List<String> skills = rowStates.map((e) => e.name).toList();

    Comment comment = await showDialog(
        context: context,
        builder: (BuildContext context) => NewCommentDialog(skills));

    databaseInstance.addNewComment(comment).then((value) => {
          setState(() {
            comments.add(comment);
          })
        });
  }

  void showAddNewGoalDialog() async {
    List<String> skills = rowStates.map((e) => e.name).toList();
    List<String> goalsAlreadySet = goals.map((e) => e.name).toList();
    skills.removeWhere((element) => goalsAlreadySet.contains(element));

    if (skills.isNotEmpty) {
      Goal? goal = await showDialog(
          context: context,
          builder: (BuildContext context) => NewGoalDialog(skills));

      if (goal != null) {
        databaseInstance.addNewGoal(goal).then((value) => setState(() {
              goals.add(goal);
            }));
      }
    } else {
      showErrorMessage('No tasks added yet');
    }
  }

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

  void showErrorMessage(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        duration: secondDuration));
  }
}
