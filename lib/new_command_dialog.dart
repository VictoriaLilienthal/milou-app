import 'package:flutter/material.dart';

class AddNewCommandWidget extends StatelessWidget {
  final Function isValidSkillName;
  final Function onError;

  const AddNewCommandWidget(this.isValidSkillName, this.onError, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController textFieldController = TextEditingController();

    handleText() {
      if (textFieldController.text.isNotEmpty &&
          isValidSkillName(textFieldController.text)) {
        Navigator.pop(context, textFieldController.text);
      } else {
        onError();
      }
    }

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
              handleText();
            },
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.check),
          color: Colors.green,
          onPressed: () {
            handleText();
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
