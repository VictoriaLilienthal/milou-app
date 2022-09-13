import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milou_app/export.dart';
import 'package:spring/spring.dart';

import 'data/comment.dart';

class NotesWidget extends StatefulWidget {
  final List<Comment> comments;
  const NotesWidget(this.comments, {Key? key}) : super(key: key);

  @override
  NotesWidgetState createState() => NotesWidgetState();
}

class NotesWidgetState extends State<NotesWidget> {
  final SpringController springController =
      SpringController(initialAnim: Motion.pause);

  @override
  Widget build(BuildContext context) {
    List<Widget> li = [];

    li.add(Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
            onPressed: () => {Export.exportComments(widget.comments)},
            icon: const Icon(Icons.download))
      ],
    ));
    for (int i = 0; i < widget.comments.length; i++) {
      var comment = widget.comments[i];
      li.add(Dismissible(
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return showDialog(
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
              return value;
            }
            return null;
          });
        },
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
        key: Key("c_$i"),
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Text(DateFormat.yMMMd().format(
                        DateTime.fromMillisecondsSinceEpoch(comment.time))),
                    comment.skillName.isNotEmpty
                        ? Text("  ${comment.skillName}  ")
                        : const Text("  "),
                    Flexible(child: Text(comment.comment))
                  ],
                ))),
      ));
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
