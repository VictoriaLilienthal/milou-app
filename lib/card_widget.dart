import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:spring/spring.dart';
import 'package:vibration/vibration.dart';

import 'data/db.dart';
import 'data/goal.dart';
import 'data/logs.dart';
import 'data/skill.dart';

const IconData paws = IconData(0xe4a1, fontFamily: 'MaterialIcons');

class CardWidget extends StatefulWidget {
  final Skill state;
  final Function onShowChart;
  final Function onUnmastered;
  final Function onDelete;
  final Function onMastered;
  final Goal? goal;

  const CardWidget(this.state,
      {required Key? key,
      required this.onShowChart,
      required this.onUnmastered,
      required this.onDelete,
      required this.onMastered,
      this.goal})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CardWidgetState();

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
}

class _CardWidgetState extends State<CardWidget> {
  bool isBig = false;
  Logs logs = Logs();

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      DB()
          .getLogsForSkill(widget.state.name)
          .then((value) => setState(() => {logs = value}));
    }
  }

  Widget getLeadingIcon() {
    Skill state = widget.state;
    if (state.mastered) {
      return Spring.bubbleButton(
          child: IconButton(
              icon: const Icon(
                Icons.star,
                size: 24,
                color: Colors.yellow,
              ),
              onPressed: () => {widget.onUnmastered()}));
    } else if (widget.goal == null) {
      return Spring.bubbleButton(
        child: const Icon(
          paws,
          size: 24,
          color: Colors.green,
        ),
      );
    } else {
      int sign = getSign();
      switch (sign) {
        case 0:
          {
            return Spring.scale(
              animDuration: const Duration(milliseconds: 200),
              start: 0.1,
              end: 1,
              child: const Icon(
                Icons.check,
                size: 24,
                color: Colors.yellow,
              ),
            );
          }
        case 1:
          {
            return Spring.bubbleButton(
                child: CircularPercentIndicator(
              radius: 12,
              lineWidth: 3.0,
              percent: min(goalProgress(), 1),
              center: Text(
                "${max((widget.goal!.target - getCnt()), 0)}",
                style: const TextStyle(fontSize: 10),
              ),
              progressColor: Colors.green,
            ));
          }
        case -1:
          {
            return Spring.bubbleButton(
                child: const Icon(
              Icons.check,
              size: 24,
              color: Colors.yellow,
            ));
          }
      }
      return Spring.bubbleButton(
          child: IconButton(
        icon: const Icon(
          paws,
          size: 24,
          color: Colors.green,
        ),
        onPressed: () {},
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Skill state = widget.state;

    List<Widget> kids = [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      getLeadingIcon(),
                      Flexible(
                        child: Text(
                          "  ${state.name}",
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          iconSize: 48,
                          color: Colors.green,
                          onPressed: () => {
                                setState(() {
                                  state.cnt += 1;
                                  state.todayCnt += 1;
                                  state.lastActivity =
                                      DateTime.now().millisecondsSinceEpoch;
                                  DB().addClick(state.name, 1);
                                  vibrateIfGoalComplete(state);
                                })
                              },
                          icon: const Icon(LineAwesomeIcons.plus_circle)),
                      IconButton(
                        icon: const Icon(
                          Icons.bar_chart,
                          size: 24,
                          color: Colors.blue,
                        ),
                        onPressed: () => widget.onShowChart(),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text(dateFmt(state))),
                Expanded(child: Text('today ${state.todayCnt}')),
                Expanded(child: Text('All time ${state.cnt}')),
              ],
            ),
          ],
        ),
      ),
    ];

    if (widget.goal != null) {
      kids.add(LinearProgressIndicator(
        value: goalProgress(),
      ));
    }
    return Dismissible(
      key: Key(state.name),
      direction: DismissDirection.horizontal,
      background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          color: Colors.green,
          child: AnimatedSize(
            alignment: Alignment.center,
            duration: const Duration(milliseconds: 100),
            child: Icon(
              Icons.star,
              color: Colors.white,
              size: isBig ? 45 : 30,
            ),
          )),
      secondaryBackground: Container(
          padding: const EdgeInsets.only(right: 20),
          alignment: Alignment.centerRight,
          color: Colors.redAccent,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 100),
            child: Icon(
              Icons.delete,
              color: Colors.white,
              size: isBig ? 45 : 30,
            ),
          )),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          showDialog(
              context: context,
              builder: ((context) {
                return AlertDialog(
                  title: const Text('Delete?'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const <Widget>[Text('Confirm Delete')],
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.check),
                      color: Colors.green,
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel),
                      color: Colors.red,
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ],
                );
              })).then((value) {
            if (value) {
              widget.onDelete();
            }
          });
          return false;
        } else if (direction == DismissDirection.startToEnd) {
          widget.onMastered();
          return false;
        }
        return null;
      },
      onUpdate: (details) {
        if (details.reached) {
          setState(() {
            isBig = true;
          });
        } else {
          setState(() {
            isBig = false;
          });
        }
      },
      child: Card(
          child: Column(
        children: kids,
      )),
    );
  }

  static String dateFmt(Skill state) {
    if (state.cnt == 0 || state.lastActivity == 0) {
      return "Never Performed";
    } else {
      DateTime lastDate =
          DateTime.fromMillisecondsSinceEpoch(state.lastActivity);
      if (CardWidget.isToday(state.lastActivity)) {
        return "Last performed today";
      }
      return "Last performed ${(DateFormat.yMMMd().format(lastDate))}";
    }
  }

  void vibrateIfGoalComplete(Skill state) async {
    if (widget.goal!.target == getCnt()) {
      Vibration.hasVibrator().then((value) {
        if (value != null && value) {
          Vibration.vibrate(duration: 200);
        }
      });
    }
  }

  int getSign() {
    return (widget.goal!.target - getCnt()).sign;
  }

  double goalProgress() {
    return getCnt() / widget.goal!.target;
  }

  double weeklyGoalProgress() {
    return getCntTowardsGoal() / widget.goal!.target;
  }

  int getCntTowardsGoal() {
    if (widget.goal!.type == 0) {
      return widget.state.todayCnt;
    }

    DateTime creationTime =
        DateTime.fromMillisecondsSinceEpoch(widget.state.creationTime);

    DateTime endTime = creationTime.add(const Duration(days: 7));

    int cnt = logs.logs
        .where((element) =>
            creationTime.millisecondsSinceEpoch <= element &&
            element <= endTime.millisecondsSinceEpoch)
        .length;

    return cnt;
  }

  int getCnt() {
    DateTime creationTime =
        DateTime.fromMillisecondsSinceEpoch(widget.goal!.creationTime);
    DateTime now = DateTime.now();
    print(now.difference(creationTime).inDays);

    if (widget.goal != null) {
      if (widget.goal!.isRecurring) {
        if (widget.goal!.type == 0) {
          return widget.state.todayCnt;
        } else {
          Duration d = now.difference(creationTime);
          int i = 7 * ((d.inDays / 7).ceil());

          DateTime startTime = now.subtract(Duration(days: i));
          DateTime endTime = startTime.add(const Duration(days: 7));

          return logs.logs
              .where((element) =>
                  startTime.millisecondsSinceEpoch <= element &&
                  element <= endTime.millisecondsSinceEpoch)
              .length;
        }
      } else {
        if (widget.goal!.type == 0) {
          if (now.difference(creationTime).inHours < 24) {
            return widget.state.todayCnt;
          }
        } else {
          if (now.difference(creationTime).inDays < 7) {
            DateTime endTime = creationTime.add(const Duration(days: 7));
            return logs.logs
                .where((element) =>
                    creationTime.millisecondsSinceEpoch <= element &&
                    element <= endTime.millisecondsSinceEpoch)
                .length;
          }
        }
      }
    }

    return 0;
  }
}
