import 'dart:convert';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import 'chart.dart';
import 'drawer.dart';
import 'mastered_prompt_dialog.dart';
import 'new_command_widgets.dart';
import 'rowstate.dart';
import 'storage.dart';

final prefs = SharedPreferences.getInstance();
const IconData pets = IconData(0xe4a1, fontFamily: 'MaterialIcons');

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
  List<RowState> rowStates = <RowState>[];

  @override
  void initState() {
    super.initState();

    Storage.get('data').then((value) => setState(() {
          if (value != null) {
            jsonDecode(value.toString())
                .forEach((item) => rowStates.add(RowState.fromJson(item)));
          }
        }));
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
          body: TabBarView(
            children: <Widget>[
              getCommandWidgets(),
              const Center(
                child: SpinKitDancingSquare(
                  color: Colors.blue,
                  size: 50.0,
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: showAddNewCommandDialog,
            tooltip: 'Add new command',
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        ));
  }

  // Gets the display date format for "last performed" text
  static String dateFmt(RowState state) {
    if (state.logs.isEmpty) {
      return "Never Performed";
    } else {
      DateTime lastDate =
          DateTime.fromMillisecondsSinceEpoch(state.logs.last.item2);

      if (lastDate.day == DateTime.now().day &&
          lastDate.month == DateTime.now().month &&
          lastDate.year == DateTime.now().year) {
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
    str.then((value) => setState(() {
          if (value != null) {
            rowStates.add(RowState(const Uuid().v4(), value.toString()));
            Storage.store('data', jsonEncode(rowStates));
          }
        }));
  }

  Widget getCommandWidgets() {
    List<Widget> list = <Widget>[];
    for (var i = 0; i < rowStates.length; i++) {
      RowState state = rowStates[i];
      int todayCnt = state.logs.where((f) {
        DateTime d = DateTime.fromMillisecondsSinceEpoch(f.item2);
        if (d.day == DateTime.now().day &&
            d.month == DateTime.now().month &&
            d.year == DateTime.now().year) {
          return true;
        }
        return false;
      }).length;

      //Swipe to delete
      Widget card = Dismissible(
        key: Key(state.id),
        direction: DismissDirection.horizontal,
        background: Container(
            alignment: Alignment.centerRight, color: Colors.green),
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
            setState(() {
              rowStates.removeAt(i);
            });
            Storage.store('data', jsonEncode(rowStates));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${state.name} deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    setState(() {
                      rowStates.insert(i, state);
                    });
                    Storage.store('data', jsonEncode(rowStates));
                  },
                )));
            return true;
          } else if (direction == DismissDirection.startToEnd) {
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() {
                rowStates.removeAt(i);
                state.mastered = true;
                rowStates.add(state);
              });
              Storage.store('data', jsonEncode(rowStates));
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
                    state.logs.add(Tuple2<bool, int>(
                        true, DateTime.now().millisecondsSinceEpoch));
                    Storage.store('data', jsonEncode(rowStates));

                    if (state.logs.length == 60 && !state.mastered) {
                      Future<bool?> b = showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              buildMarkStarredDialog(context));
                      b.then((value) {
                        if (value != null && value) {
                          setState(() {
                            state.mastered = true;
                          });
                          Storage.store('data', jsonEncode(rowStates));
                        }
                      });
                    }
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
                                            Storage.store(
                                                'data', jsonEncode(rowStates));
                                          });
                                        },
                                      )
                                    : IconButton(
                                        icon: const Icon(
                                          pets,
                                          size: 30,
                                          color: Colors.green,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            state.cnt += 1;
                                            state.logs.add(Tuple2<bool, int>(
                                                true,
                                                DateTime.now()
                                                    .millisecondsSinceEpoch));
                                            Storage.store(
                                                'data', jsonEncode(rowStates));
                                          });
                                        },
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
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        SimpleTimeSeriesChart.fromLogs(
                                            state.logs)));
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
                final RowState element = rowStates.removeAt(oldIndex);
                rowStates.insert(newIndex, element);
                Storage.store('data', jsonEncode(rowStates));
              });
            },
            children: list));
  }
}
