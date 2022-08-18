import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:spring/spring.dart';

import 'skill.dart';

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

  @override
  Widget build(BuildContext context) {
    Skill state = widget.state;

    Widget getLeadingIcon() {
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
            child: IconButton(
          icon: const Icon(
            paws,
            size: 24,
            color: Colors.green,
          ),
          onPressed: () {},
        ));
      } else {
        int sign = (widget.goal!.target - state.todayCnt).sign;
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
                percent: state.todayCnt / widget.goal!.target > 1
                    ? 1
                    : state.todayCnt / widget.goal!.target,
                center: Text(
                  state.todayCnt > widget.goal!.target
                      ? "0"
                      : "${widget.goal!.target - state.todayCnt}",
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

    List<Widget> kids = [
      Padding(
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
                      getLeadingIcon(),
                      Text(
                        "  ${state.name}",
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
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
        value: state.todayCnt / widget.goal!.target,
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
          child: InkWell(
              onTap: () {
                setState(() {
                  state.cnt += 1;
                  state.todayCnt += 1;
                  state.lastActivity = DateTime.now().millisecondsSinceEpoch;
                  DB().addClick(state.name);
                });
              },
              child: Column(
                children: kids,
              ))),
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
}
