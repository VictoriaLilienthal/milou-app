import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:milou_app/skill.dart';

class GoalsPage extends StatefulWidget {
  final List<Goal> goals;
  const GoalsPage(this.goals, {Key? key}) : super(key: key);

  @override
  GoalsPageState createState() => GoalsPageState();
}

class GoalsPageState extends State<GoalsPage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> li = [];

    for (Goal g in widget.goals) {
      li.add(Dismissible(
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
                    value: g.target,
                    max: 100,
                    divisions: 100,
                    label: g.target.toString(),
                    onChanged: null,
                  )
                ]),
              ),
              IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.green,
                  ),
                  onPressed: () => {}),
              IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () => {})
            ]),
          ))));
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
