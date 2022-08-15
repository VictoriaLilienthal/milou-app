import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({Key? key}) : super(key: key);

  @override
  GoalsPageState createState() => GoalsPageState();
}

class GoalsPageState extends State<GoalsPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SpinKitDancingSquare(
        color: Colors.blue,
        size: 50.0,
      ),
    );
  }
}
