import 'dart:ui';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<charts.Series<dynamic, DateTime>> seriesList;

  const SimpleTimeSeriesChart(this.seriesList, {super.key});

  factory SimpleTimeSeriesChart.fromLogs(List<Tuple2<bool, int>> logs) {
    return SimpleTimeSeriesChart(_createChartDataFromLogs(logs));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: charts.TimeSeriesChart(
                seriesList,
                animate: true,
                dateTimeFactory: const charts.LocalDateTimeFactory(),
              ),
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: 'Back',
          child: const Icon(Icons.close_fullscreen),
        ));
  }

  static List<charts.Series<TimeSeriesData, DateTime>> _createChartDataFromLogs(
      List<Tuple2<bool, int>> logs) {
    final Map counts = {};
    Duration day = const Duration(days: 1);
    DateTime today = DateTime.now();
    for (int i = 0; i < 7; i += 1) {
      DateTime t = DateTime(today.year, today.month, today.day);
      counts[t] = 0;
      today = today.subtract(day);
    }

    for (var e in logs) {
      DateTime d = DateTime.fromMillisecondsSinceEpoch(e.item2);
      DateTime t = DateTime(d.year, d.month, d.day);
      if (counts.containsKey(t)) {
        counts[t] += 1;
      } else {
        counts[t] = 1;
      }
    }

    final List<TimeSeriesData> data = [];

    counts.forEach((key, value) => data.add(TimeSeriesData(key, value)));

    return [
      charts.Series<TimeSeriesData, DateTime>(
        id: 'Training Logs',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesData sales, _) => sales.time,
        measureFn: (TimeSeriesData sales, _) => sales.cnt,
        data: data,
      )
    ];
  }
}

/// Sample time series data type.
class TimeSeriesData {
  final DateTime time;
  final int cnt;

  TimeSeriesData(this.time, this.cnt);
}
