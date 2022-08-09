import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:milou_app/chart.dart';
import 'package:tuple/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uuid/uuid.dart';
import 'main.dart';
import 'rowstate.dart';
import 'storage.dart';

final prefs = SharedPreferences.getInstance();
const IconData pets = IconData(0xe4a1, fontFamily: 'MaterialIcons');

class HomeApp extends StatelessWidget {
  const HomeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Milou App',
      home: MainApp(title: 'Milou'),
    );
  }
}

Widget _buildPopupDialog(BuildContext context) {
  final textFieldController = TextEditingController();
  return AlertDialog(
    title: const Text('New Command'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: textFieldController,
          decoration: const InputDecoration(hintText: "Command"),
        ),
      ],
    ),
    actions: <Widget>[
      IconButton(
        icon: const Icon(Icons.check),
        color: Colors.green,
        onPressed: () {
          if (textFieldController.text.isNotEmpty) {
            Navigator.pop(context, textFieldController.text);
          }
        },
      ),
      IconButton(
        icon: const Icon(Icons.cancel),
        color: Colors.red,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}

class MainApp extends StatefulWidget {
  const MainApp({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<RowState> rowStates = <RowState>[];

  @override
  void initState() {
    super.initState();
    if (Storage.has('data')) {
      setState(() {
        jsonDecode(Storage.get('data').toString())
            .forEach((item) => rowStates.add(RowState.fromJson(item)));
      });
    }
  }

  String dateFmt(RowState state) {
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
        direction: DismissDirection.endToStart,
        background: Container(
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
        onDismissed: (direction) {
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
        },
        child: Card(
            child: InkWell(
                onTap: () {
                  setState(() {
                    state.cnt += 1;
                    state.logs.add(Tuple2<bool, int>(
                        true, DateTime.now().millisecondsSinceEpoch));
                    Storage.store('data', jsonEncode(rowStates));
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
                                IconButton(
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
                            //Delete Button
                            // IconButton(
                            //   icon: const Icon(
                            //     Icons.delete,
                            //     size: 30,
                            //     color: Colors.red,
                            //   ),
                            //   onPressed: () {
                            //     setState(() {
                            //       rowStates.removeAt(i);
                            //     });
                            //     Storage.store('data', jsonEncode(rowStates));
                            //   },
                            // ),
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
                              child: Text('${dateFmt(state)}',
                                  style:
                                      Theme.of(context).textTheme.bodyText1)),
                          Expanded(
                              child: Text('today ${todayCnt}',
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
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
          drawer: Drawer(
              child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
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
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => profileScreen));
                },
              ),
            ],
          )),
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
            onPressed: () {
              Future<String?> str = showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildPopupDialog(context));
              str.then((value) => setState(() {
                    if (value != null) {
                      rowStates
                          .add(RowState(const Uuid().v4(), value.toString()));
                      Storage.store('data', jsonEncode(rowStates));
                    }
                  }));
            },
            tooltip: 'Add new command',
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        ));
  }

  void _closeDrawer() {
    Navigator.of(context).pop();
  }

  void showChart(RowState state) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Training logs'),
              content: SimpleTimeSeriesChart.fromLogs(state.logs),
              actions: <Widget>[
                TextButton(
                  child: const Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }
}
