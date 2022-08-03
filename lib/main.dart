import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Milou'),
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
      jsonDecode(prefs.getString('data').toString()).forEach((item) => rowStates.add(RowState.fromJson(item)));
      setState(() {
      });
    });
  }

  Widget getCommandWidgets(List<RowState> rowStates) {
    List<Widget> list = <Widget>[];
    for (var i = 0; i < rowStates.length; i++) {
      bool enabled = true;
      RowState state = rowStates[i];
      list.add(Card(
          child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      Text(state.name),
                      IconButton(
                        icon: const Icon(
                          Icons.check,
                          size: 30,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            state.cnt += 1;
                            state.logs.add(Tuple2<bool, int>(
                                true, DateTime.now().millisecondsSinceEpoch));
                            _prefs.then((value) =>
                                value.setString('data', jsonEncode(rowStates)));
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: Text(
                              'Milou has done this command ${state.cnt} number of time successfully',
                              style: Theme.of(context).textTheme.bodyText1))
                    ],
                  )
                ],
              ))));
    }
    return Column(children: list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            getCommandWidgets(rowStates),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Future<String?> str = showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialog(context));
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
    );
  }
}
