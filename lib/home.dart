import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card_widget.dart';
import 'chart.dart';
import 'drawer.dart';
import 'mastered_prompt_dialog.dart';
import 'new_command_widgets.dart';
import 'skill.dart';

final prefs = SharedPreferences.getInstance();
const IconData pets = IconData(0xe4a1, fontFamily: 'MaterialIcons');
const Duration secondDuration = Duration(milliseconds: 1000);
const Duration halfSecond = Duration(milliseconds: 1000);

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
  List<Skill> rowStates = <Skill>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    DB().getAllSkills().then((value) {
      setState(() {
        _loading = false;
        rowStates.addAll(value);
        rowStates.sort((a, b) {
          if (a.order < b.order) {
            return -1;
          } else if (a.order > b.order) {
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
        child: Scaffold(
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
              getCommandWidgets(),
              const Center(
                child: SpinKitDancingSquare(
                  color: Colors.blue,
                  size: 50.0,
                ),
              ),
            ],
          )),
          floatingActionButton: FloatingActionButton(
            onPressed: showAddNewCommandDialog,
            tooltip: 'Add new command',
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        ));
  }

  // Show the add new command dialog box
  void showAddNewCommandDialog() async {
    Future<String?> str = showDialog(
        context: context,
        builder: (BuildContext context) =>
            AddNewCommandWidget(checkDuplicateSkill));

    str.then((value) {
      if (value != null && !checkDuplicateSkill(value)) {
        Skill s = Skill(value);

        DB().addNewSkill(s).then((value) {
          setState(
            () {
              rowStates.add(s);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('New skill ${s.name} Added'),
                  duration: secondDuration));
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

  Widget getCommandWidgets() {
    List<Widget> list = <Widget>[];
    for (var i = 0; i < rowStates.length; i++) {
      Skill state = rowStates[i];

      list.add(CardWidget(
        state,
        key: Key(state.name),
        showChart: () => DB().getLogsForSkill(state.name).then((value) =>
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SimpleTimeSeriesChart.fromLogs(value)))),
        onDelete: () {
          setState(() {
            rowStates.removeAt(i);
          });
          _loading = true;
          DB().delete(state.name).then((value) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('${state.name} deleted')));
            DB()
                .syncOrder(rowStates)
                .then((value) => setState(() => {_loading = false}));
          });
        },
        onMastered: () => Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            state.mastered = true;
            _loading = true;
          });

          if (i != rowStates.length - 1) {
            rowStates.removeAt(i);
            rowStates.add(state);
          }

          DB().updateSkill(state).then((value) => {
                DB().syncOrder(rowStates).then((value) {
                  setState(() {
                    _loading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${state.name} mastered'),
                      duration: halfSecond));
                })
              });
        }),
        onUnmastered: () {
          setState(() {
            state.mastered = false;
            _loading = true;
          });
          DB().updateSkill(state).then((value) => setState(() {
                _loading = false;
              }));
        },
      ));
    }

    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: ReorderableListView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final Skill element = rowStates.removeAt(oldIndex);
                rowStates.insert(newIndex, element);
                _loading = true;
                DB()
                    .syncOrder(rowStates)
                    .then((value) => setState(() => {_loading = false}));
              });
            },
            children: list));
  }

  bool checkDuplicateSkill(String value) {
    if (value.isEmpty) {
      return true;
    }
    for (Skill s in rowStates) {
      if (s.name.compareTo(value) == 0) {
        return true;
      }
    }
    return false;
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
