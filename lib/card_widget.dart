import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'skill.dart';

const IconData pets = IconData(0xe4a1, fontFamily: 'MaterialIcons');

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
                      state.mastered
                          ? IconButton(
                              icon: const Icon(
                                Icons.star,
                                size: 24,
                                color: Colors.yellow,
                              ),
                              onPressed: () => {widget.onUnmastered()})
                          : widget.goal != null
                              ? CircularPercentIndicator(
                                  radius: 12,
                                  lineWidth: 3.0,
                                  percent:
                                      state.todayCnt / widget.goal!.target > 1
                                          ? 1
                                          : state.todayCnt /
                                              widget.goal!.target,
                                  center: Text(
                                    state.todayCnt > widget.goal!.target
                                        ? "0"
                                        : "${widget.goal!.target - state.todayCnt}",
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  progressColor: Colors.green,
                                )
                              : IconButton(
                                  icon: const Icon(
                                    pets,
                                    size: 24,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {},
                                ),
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
        value: state.cnt / widget.goal!.target,
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
          widget.onDelete();
          return true;
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
