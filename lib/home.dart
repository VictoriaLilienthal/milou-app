import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

List<Tuple2<bool, int>> fromJsonToTupleList(String json) {
  Iterable iterable = jsonDecode(json);

  List newList = iterable.toList();

  final newTuples = newList
      .map(
        (e) => Tuple2<bool, int>(
          e['1'],
          e['2'],
        ),
      )
      .toList();
  return newTuples;
}

String toJsonFromTupleList(List<Tuple2> tuples) {
  List list = tuples
      .map(
        (e) => {
          '1': e.item1,
          '2': e.item2,
        },
      )
      .toList();

  String json = jsonEncode(list);
  return json;
}

class RowState {
  String name;
  int cnt;
  List<Tuple2<bool, int>> logs;

  RowState(this.name, this.cnt, this.logs);

  Map<String, dynamic> toJson() => {
        'name': name,
        'cnt': cnt,
        'logs': toJsonFromTupleList(logs),
      };

  RowState.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        cnt = json['cnt'],
        logs = fromJsonToTupleList(json['logs']);
}

final prefs = SharedPreferences.getInstance();

class HomeApp extends StatelessWidget {
  const HomeApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Milou'),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<RowState> rowStates = <RowState>[];

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      if (prefs.containsKey('data')) {
        jsonDecode(prefs.getString('data').toString())
            .forEach((item) => rowStates.add(RowState.fromJson(item)));
      }
      setState(() {});
    });
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
      bool enabled = true;
      const IconData pets = IconData(0xe4a1, fontFamily: 'MaterialIcons');

      RowState state = rowStates[i];

      int today_cnt = state.logs.where((f) {
        DateTime d = DateTime.fromMillisecondsSinceEpoch(f.item2);
        if (d.day == DateTime.now().day &&
            d.month == DateTime.now().month &&
            d.year == DateTime.now().year) {
          return true;
        }
        return false;
      }).length;

      list.add(Card(
          key: Key(state.name),
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
                                  state.logs.add(Tuple2<bool, int>(true,
                                      DateTime.now().millisecondsSinceEpoch));
                                  _prefs.then((value) => value.setString(
                                      'data', jsonEncode(rowStates)));
                                });
                              },
                            ),
                            Text(
                              state.name,
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 30,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            rowStates.removeAt(i);
                            _prefs.then((value) =>
                                value.setString('data', jsonEncode(rowStates)));
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded( child: Text('${dateFmt(state)}',
                          style: Theme.of(context).textTheme.bodyText1)),
                      Expanded( child: Text('today ${today_cnt}',
                          style: Theme.of(context).textTheme.bodyText1)),
                      Expanded( child: Text('All time ${state.cnt}',
                          style: Theme.of(context).textTheme.bodyText1)),
                    ],
                  )
                ],
              ))));
    }

    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: ReorderableListView(
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                oldIndex = (oldIndex < 0) ? 0 : oldIndex;
                newIndex = newIndex >= rowStates.length
                    ? (rowStates.length - 1)
                    : newIndex;
                final temp = rowStates[oldIndex];
                rowStates[oldIndex] = rowStates[newIndex];
                rowStates[newIndex] = temp;
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('This is the Drawer'),
                  ElevatedButton(
                    onPressed: _closeDrawer,
                    child: const Text('Close Drawer'),
                  ),
                ],
              ),
            ),
          ),
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
                      rowStates.add(RowState(value.toString(), 0, []));
                      _prefs.then((value) =>
                          value.setString('data', jsonEncode(rowStates)));
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
}

void login() async {
  // await FirebaseAuth.instance.verifyPhoneNumber(
  //   phoneNumber: '+16463844693',
  //   verificationCompleted: (PhoneAuthCredential credential) {
  //     print(1);
  //   },
  //   verificationFailed: (FirebaseAuthException e) {
  //     print(e);
  //   },
  //   codeSent: (String verificationId, int? resendToken) {
  //     PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //         verificationId: verificationId, smsCode: "123456");
  //
  //     try {
  //       _auth.signInWithCredential(credential).then((value) => {print(value)});
  //     } on FirebaseAuthException catch (e) {
  //       print(e);
  //     }
  //   },
  //   codeAutoRetrievalTimeout: (String verificationId) {
  //     print(3);
  //   },
  // );
}
