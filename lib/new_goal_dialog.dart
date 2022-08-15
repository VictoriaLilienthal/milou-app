import 'package:flutter/material.dart';
import 'package:milou_app/skill.dart';

class NewGoalDialog extends StatefulWidget {
  final List<String> skillNames;

  const NewGoalDialog(this.skillNames, {Key? key}) : super(key: key);

  @override
  _NewGoalDialogState createState() => _NewGoalDialogState();
}

class _NewGoalDialogState extends State<NewGoalDialog> {
  String dropdownValue = "";
  double _currentSliderValue = 60;

  @override
  Widget build(BuildContext context) {
    if (dropdownValue.isEmpty) {
      dropdownValue = widget.skillNames.first;
    }
    return AlertDialog(
      title: const Text('New Goal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          DropdownButton<String>(
            value: dropdownValue,
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
            },
            items: getListItems(),
          ),
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
          )
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.check),
          color: Colors.green,
          onPressed: () {
            Navigator.pop(context, Goal(dropdownValue, _currentSliderValue));
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
