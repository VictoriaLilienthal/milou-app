import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

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
Widget buildNewCommandDialog(BuildContext context) {
  return const AddNewCommandWidget();
}

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
          if (!isToday(rowStates[i].lastActivity)) {
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

  static bool isToday(int date) {
    DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(date);
    DateTime today = DateTime.now();
    if (lastDate.day == today.day &&
        lastDate.month == today.month &&
        lastDate.year == today.year) {
      return true;
    }
    return false;
  }

  static String dateFmt(Skill state) {
    if (state.cnt == 0 || state.lastActivity == 0) {
      return "Never Performed";
    } else {
      DateTime lastDate =
          DateTime.fromMillisecondsSinceEpoch(state.lastActivity);
      if (isToday(state.lastActivity)) {
        return "Last performed today";
      }
      return "Last performed ${(DateFormat.yMMMd().format(lastDate))}";
    }
  }

  // Show the add new command dialog box
  void showAddNewCommandDialog() async {
    Future<String?> str = showDialog(
        context: context,
        builder: (BuildContext context) => buildNewCommandDialog(context));

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
      int todayCnt = state.todayCnt;
      //Swipe to delete
      Widget card = Dismissible(
        key: Key(state.name),
        direction: DismissDirection.horizontal,
        background: Container(
            alignment: Alignment.centerLeft,
            color: Colors.green,
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 30,
            )),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          color: Colors.redAccent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text("Delete ",
                  style: TextStyle(fontSize: 30, color: Colors.white)),
              Icon(
                Icons.delete,
                size: 30,
                color: Colors.white,
              )
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            String name = rowStates[i].name;

            setState(() {
              rowStates.removeAt(i);
            });
            _loading = false;
            DB().delete(name).then((value) {
              _loading = true;
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${state.name} deleted')));
              DB()
                  .syncOrder(rowStates)
                  .then((value) => setState(() => {_loading = false}));
            });

            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //     content: Text('${state.name} deleted'),
            //     action: SnackBarAction(
            //       label: 'Undo',
            //       onPressed: () {
            //         setState(() {
            //           rowStates.insert(i, state);
            //         });
            //         // TODO : Restore the data
            //       },
            //     )));
            return true;
          } else if (direction == DismissDirection.startToEnd) {
            Future.delayed(const Duration(milliseconds: 300), () {
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
            });
            return false;
          }
          return null;
        },
        child: Card(
            child: InkWell(
                onTap: () {
                  setState(() {
                    state.cnt += 1;
                    state.todayCnt += 1;
                    state.lastActivity = DateTime.now().millisecondsSinceEpoch;
                    DB().addClick(state.name);
                    // TODO : fix counting for new model
                    // if (state.logs.length == 60 && !state.mastered) {
                    //   Future<bool?> b = showDialog(
                    //       context: context,
                    //       builder: (BuildContext context) =>
                    //           buildMarkStarredDialog(context));
                    //   b.then((value) {
                    //     if (value != null && value) {
                    //       setState(() {
                    //         state.mastered = true;
                    //       });
                    //       Storage.store('data', jsonEncode(rowStates));
                    //     }
                    //   });
                    // }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: [
                                state.mastered
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.star,
                                          size: 30,
                                          color: Colors.green,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            state.mastered = false;
                                            _loading = true;
                                          });
                                          DB()
                                              .updateSkill(state)
                                              .then((value) => setState(() {
                                                    _loading = false;
                                                  }));
                                        },
                                      )
                                    : IconButton(
                                        icon: const Icon(
                                          pets,
                                          size: 30,
                                          color: Colors.green,
                                        ),
                                        onPressed: () {},
                                      ),
                                Text(
                                  state.name,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.bar_chart,
                                size: 30,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                DB().getLogsForSkill(state.name).then((value) =>
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SimpleTimeSeriesChart.fromLogs(
                                                    value))));
                              },
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Text(dateFmt(state),
                                  style:
                                      Theme.of(context).textTheme.bodyText1)),
                          Expanded(
                              child: Text('today $todayCnt',
                                  style:
                                      Theme.of(context).textTheme.bodyText1)),
                          Expanded(
                              child: Text('All time ${state.cnt}',
                                  style:
                                      Theme.of(context).textTheme.bodyText1)),
                        ],
                      )
                    ],
                  ),
                ))),
      );


      list.add(card);
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
