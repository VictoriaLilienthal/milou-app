import 'package:flutter/material.dart';

import 'data/goal.dart';

class NewGoalDialog extends StatefulWidget {
  final List<String> skillNames;

  const NewGoalDialog(this.skillNames, {Key? key}) : super(key: key);

  @override
  NewGoalDialogState createState() => NewGoalDialogState();
}

class NewGoalDialogState extends State<NewGoalDialog> {
  String goalName = "";
  double _currentSliderValue = 60;
  int goalType = 0;
  bool recurring = false;

  @override
  Widget build(BuildContext context) {
    if (goalName.isEmpty) {
      goalName = widget.skillNames.first;
    }
    return AlertDialog(
      title: const Text('New Goal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          DropdownButton<String>(
            value: goalName,
            onChanged: (String? newValue) {
              setState(() {
                goalName = newValue!;
              });
            },
            items: getListItems(),
          ),
          Row(
            children: [
              const Text("Value"),
              Slider(
                value: _currentSliderValue,
                max: 100,
                divisions: 100,
                label: _currentSliderValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _currentSliderValue = value;
                  });
                },
              ),
              Text("  ${_currentSliderValue.round()}")
            ],
          ),
          SwitchListTile(
            title: const Text('Recurring'),
            value: recurring,
            onChanged: (bool value) {
              setState(() {
                recurring = value;
              });
            },
          ),
          DropdownButton<int>(
            value: goalType,
            onChanged: (int? newValue) {
              setState(() {
                goalType = newValue!;
              });
            },
            items: const [
              DropdownMenuItem(value: 0, child: Text("Daily")),
              DropdownMenuItem(value: 1, child: Text("Weekly"))
            ],
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.check),
          color: Colors.green,
          onPressed: () {
            Navigator.pop(
                context,
                Goal(goalName, _currentSliderValue.toInt(), goalType, recurring,
                    DateTime.now().millisecondsSinceEpoch, false));
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

  List<DropdownMenuItem<String>> getListItems() {
    List<DropdownMenuItem<String>> l = [];
    for (String s in widget.skillNames) {
      l.add(DropdownMenuItem(value: s, child: Text(s)));
    }
    return l;
  }
}
