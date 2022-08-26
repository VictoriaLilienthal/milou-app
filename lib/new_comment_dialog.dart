import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/comment.dart';

class NewCommentDialog extends StatefulWidget {
  final List<String> skillNames;

  const NewCommentDialog(this.skillNames, {Key? key}) : super(key: key);

  @override
  NewCommentDialogState createState() => NewCommentDialogState();
}

class NewCommentDialogState extends State<NewCommentDialog> {
  late String skillName;
  late DateTime selectedTime;
  late String dateTimeStr;
  late TextEditingController textFieldController;

  @override
  void initState() {
    super.initState();
    skillName = "";
    selectedTime = DateTime.now();
    dateTimeStr = DateFormat.yMMMd().format(selectedTime);
    textFieldController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Comment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextButton.icon(
            label: Text(dateTimeStr),
            icon: const Icon(Icons.date_range),
            onPressed: () {
              Future<DateTime?> f = showDatePicker(
                  context: context,
                  initialDate: selectedTime,
                  initialDatePickerMode: DatePickerMode.day,
                  firstDate: DateTime(2022),
                  lastDate: DateTime.now());
              f.then((value) {
                if (value != null) {
                  setState(() {
                    selectedTime = value;
                    dateTimeStr = DateFormat.yMMMd().format(selectedTime);
                  });
                }
              });
            },
          ),
          DropdownButton<String>(
            value: skillName,
            onChanged: (String? newValue) {
              setState(() {
                skillName = newValue!;
              });
            },
            items: getListItems(),
          ),
          TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: textFieldController,
            decoration: const InputDecoration(hintText: "Comment"),
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.check),
          color: Colors.green,
          onPressed: () {
            if (textFieldController.text.isNotEmpty) {
              Navigator.pop(
                  context,
                  Comment(textFieldController.text,
                      selectedTime.millisecondsSinceEpoch,
                      skillName: skillName,
                      creationTime: DateTime.now().millisecondsSinceEpoch));
            }
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
    l.add(const DropdownMenuItem(value: "", child: Text("")));
    for (String s in widget.skillNames) {
      l.add(DropdownMenuItem(value: s, child: Text(s)));
    }
    return l;
  }
}
