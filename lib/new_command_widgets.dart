import 'package:flutter/material.dart';

class AddNewCommandWidget extends StatelessWidget {
  final Function isValidSkillName;

  const AddNewCommandWidget(this.isValidSkillName, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController textFieldController = TextEditingController();
    return AlertDialog(
      title: const Text('New Command'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: textFieldController,
            decoration: const InputDecoration(hintText: "Command"),
            onSubmitted: (value) {
              if (textFieldController.text.isNotEmpty &&
                  isValidSkillName(textFieldController.text)) {
                Navigator.pop(context, textFieldController.text);
              }
            },
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.check),
          color: Colors.green,
          onPressed: () {
            if (textFieldController.text.isNotEmpty &&
                isValidSkillName(textFieldController.text)) {
              Navigator.pop(context, textFieldController.text);
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
}
