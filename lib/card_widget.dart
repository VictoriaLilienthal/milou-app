import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'skill.dart';

const IconData pets = IconData(0xe4a1, fontFamily: 'MaterialIcons');

class CardWidget extends StatefulWidget {
  final Skill state;
  final Function showChart;
  final Function onUnmastered;
  final Function onDelete;
  final Function onMastered;

  const CardWidget(this.state,
      {Key? key,
      required this.showChart,
      required this.onUnmastered,
      required this.onDelete,
      required this.onMastered})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
    Skill state = widget.state;
    return Dismissible(
      key: Key(state.name),
      direction: DismissDirection.horizontal,
      background: Container(
          alignment: Alignment.centerLeft,
          color: Colors.green,
          child: const Icon(
            Icons.star,
            color: Colors.white,
            size: 30,
          )),
      secondaryBackground: Container(
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
                              state.mastered
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.star,
                                        size: 30,
                                        color: Colors.green,
                                      ),
                                      onPressed: widget.onUnmastered())
                                  : IconButton(
                                      icon: const Icon(
                                        pets,
                                        size: 30,
                                        color: Colors.green,
                                      ),
                                      onPressed: () {},
                                    ),
                              Text(
                                state.name,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.bar_chart,
                              size: 30,
                              color: Colors.blue,
                            ),
                            onPressed: () => widget.showChart(),
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Text(dateFmt(state),
                                style: Theme.of(context).textTheme.bodyText1)),
                        Expanded(
                            child: Text('today ${state.todayCnt}',
                                style: Theme.of(context).textTheme.bodyText1)),
                        Expanded(
                            child: Text('All time ${state.cnt}',
                                style: Theme.of(context).textTheme.bodyText1)),
                      ],
                    )
                  ],
                ),
              ))),
    );
  }

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

  static String dateFmt(Skill state) {
    if (state.cnt == 0 || state.lastActivity == 0) {
      return "Never Performed";
    } else {
      DateTime lastDate =
          DateTime.fromMillisecondsSinceEpoch(state.lastActivity);
      if (isToday(state.lastActivity)) {
        return "Last performed today";
      }
      return "Last performed ${(DateFormat.yMMMd().format(lastDate))}";
    }
  }
}
