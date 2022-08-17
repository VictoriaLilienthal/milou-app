import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:milou_app/skill.dart';

class GoalsWidget extends StatefulWidget {
  final List<Goal> goals;

  const GoalsWidget(this.goals, {Key? key}) : super(key: key);

  @override
  GoalsWidgetState createState() => GoalsWidgetState();
}

class GoalsWidgetState extends State<GoalsWidget> {
  @override
  Widget build(BuildContext context) {
    List<Widget> li = [];

    for (int i = 0; i < widget.goals.length; i++) {
      Goal g = widget.goals[i];
      li.add(GoalsListItemWidget(
          g,
          () => {
                DB().deleteGoal(g).then((value) => {widget.goals.removeAt(i)})
              }));
    }

    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: ListView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: li));
  }
}

class GoalsListItemWidget extends StatefulWidget {
  final Goal goal;
  final Function onDelete;
  const GoalsListItemWidget(this.goal, this.onDelete, {Key? key})
      : super(key: key);

  @override
  GoalsListItemWidgetState createState() => GoalsListItemWidgetState();
}

class GoalsListItemWidgetState extends State<GoalsListItemWidget> {
  bool editable = false;

  @override
  Widget build(BuildContext context) {
    Goal g = widget.goal;
    return Dismissible(
        direction: DismissDirection.endToStart,
        onDismissed: (_) => {widget.onDelete()},
        background: Container(
            padding: const EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            color: Colors.redAccent,
            child: const AnimatedSize(
              duration: Duration(milliseconds: 100),
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: 30,
              ),
            )),
        key: Key(g.name),
        child: Card(
            child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(children: [
            Expanded(
              child: Row(children: [
                Text(g.name),
                Slider(
                  value: g.target.toDouble(),
                  max: 100,
                  divisions: 100,
                  label: g.target.toString(),
                  onChanged: editable
                      ? (v) => {
                            setState(() => {g.target = v.toInt()})
                          }
                      : null,
                ),
                Text("${g.target.round()}")
              ]),
            ),
            IconButton(
                icon: Icon(
                  editable ? Icons.save : Icons.edit,
                  color: Colors.green,
                ),
                onPressed: () {
                  if (editable) {
                    DB().addNewGoal(g);
                  }
                  setState(() {
                    editable = !editable;
                  });
                }),
          ]),
        )));
  }
}
