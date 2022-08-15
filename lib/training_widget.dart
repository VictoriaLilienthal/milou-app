import 'dart:ui';

import 'package:flutter/material.dart';

import 'card_widget.dart';
import 'chart.dart';
import 'skill.dart';

const Duration halfSecond = Duration(milliseconds: 500);

class TrainingWidget extends StatefulWidget {
  final List<Skill> rowStates;

  const TrainingWidget(this.rowStates, {Key? key}) : super(key: key);

  @override
  TrainingWidgetState createState() => TrainingWidgetState();
}

class TrainingWidgetState extends State<TrainingWidget> {
  DB databaseInstance = DB();

  @override
  Widget build(BuildContext context) {
    List<Widget> list = <Widget>[];

    List<Skill> rowStates = widget.rowStates;
    for (var i = 0; i < rowStates.length; i++) {
      Skill state = rowStates[i];

      list.add(CardWidget(
        state,
        key: Key(state.name),
        showChart: () {
          databaseInstance.getLogsForSkill(state.name).then((value) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SimpleTimeSeriesChart.fromLogs(value)));
          });
        },
        onDelete: () {
          setState(() {
            rowStates.removeAt(i);
          });

          databaseInstance.delete(state.name).then((value) {
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

                databaseInstance.syncOrder(rowStates);
              });
            },
            children: list));
  }
}
