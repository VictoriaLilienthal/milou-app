import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'skill.dart';

class NotesWidget extends StatefulWidget {
  List<Comment> comments;
  NotesWidget(this.comments, {Key? key}) : super(key: key);

  @override
  _NotesWidgetState createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  @override
  Widget build(BuildContext context) {
    List<Widget> li = [];

    for (int i = 0; i < widget.comments.length; i++) {
      var comment = widget.comments[i];
      li.add(Dismissible(
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
                    Text(comment.comment)
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
