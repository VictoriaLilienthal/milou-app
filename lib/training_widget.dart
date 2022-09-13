import 'dart:ui';

import 'package:flutter/material.dart';

import 'card_widget.dart';
import 'chart.dart';
import 'data/db.dart';
import 'data/goal.dart';
import 'data/skill.dart';

const Duration halfSecond = Duration(milliseconds: 500);

class TrainingWidget extends StatefulWidget {
  final List<Skill> rowStates;
  final List<Goal> goals;
  const TrainingWidget(this.rowStates, this.goals, {Key? key})
      : super(key: key);

  @override
  TrainingWidgetState createState() => TrainingWidgetState();
}

class TrainingWidgetState extends State<TrainingWidget> {
  DB databaseInstance = DB();
  bool isList = true;

  @override
  Widget build(BuildContext context) {
    List<Widget> list = <Widget>[];

    List<Widget> buttons = <Widget>[];

    List<Skill> rowStates = widget.rowStates;
    for (var i = 0; i < rowStates.length; i += 3) {
      List<Widget> c = [];
      if (i < rowStates.length) {
        c.add(OutlinedButton(
          onPressed: () {
            debugPrint('Received click');
          },
          child: Text(rowStates[i].name),
        ));
      }
      if (i + 1 < rowStates.length) {
        c.add(IconButton(onPressed: () => {}, icon: const Icon(Icons.add)));
      }
      if (i + 2 < rowStates.length) {
        c.add(IconButton(onPressed: () => {}, icon: const Icon(Icons.add)));
      }
      buttons.add(Row(
        children: c,
      ));
    }

    for (var i = 0; i < rowStates.length; i++) {
      Skill state = rowStates[i];

      Iterable<Goal> goals = widget.goals.where((element) =>
          element.isActive() &&
          (element.name.toLowerCase() == state.name.toLowerCase()));

      list.add(CardWidget(
        state,
        goal: goals.isEmpty ? null : goals.first,
        key: Key(state.name),
        onShowChart: () {
          databaseInstance.getLogsForSkill(state.name).then((value) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    SimpleTimeSeriesChart.fromLogs(state.name, value)));
          });
        },
        onDelete: () {
          setState(() {
            rowStates.removeAt(i);
          });

          databaseInstance.deleteSkill(state.name).then((value) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('${state.name} deleted')));
            databaseInstance.syncOrder(rowStates);
          });
        },
        onMastered: () => Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            state.mastered = true;
          });

          if (i != rowStates.length - 1) {
            rowStates.removeAt(i);
            rowStates.add(state);
          }

          databaseInstance.updateSkill(state).then((value) => {
                databaseInstance.syncOrder(rowStates).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${state.name} mastered'),
                      duration: halfSecond));
                })
              });
        }),
        onUnmastered: () {
          setState(() {
            state.mastered = false;
          });
          databaseInstance.updateSkill(state);
        },
      ));
    }

    if (isList) {
      return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: Column(
            children: [
              // Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              //   TextButton(
              //     onPressed: () {
              //       setState(() {
              //         isList = !isList;
              //       });
              //     },
              //     child: Text(isList ? 'List' : 'Action'),
              //   )
              // ]),
              ReorderableListView(
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
                      databaseInstance.syncOrder(rowStates);
                    });
                  },
                  children: list)
            ],
          ));
    } else {
      return GridView.count(
        primary: false,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 3,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[100],
            child: const Text("He'd have you all unravel at the"),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[200],
            child: const Text('Heed not the rabble'),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[300],
            child: const Text('Sound of screams but the'),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[400],
            child: const Text('Who scream'),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[500],
            child: const Text('Revolution is coming...'),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[600],
            child: const Text('Revolution, they...'),
          ),
        ],
      );
    }
  }
}
