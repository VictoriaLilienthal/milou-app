import 'dart:ui';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import 'skill.dart';

class AxisTheme {
  static charts.RenderSpec<num> axisThemeNum() {
    return const charts.GridlineRendererSpec(
      labelStyle: charts.TextStyleSpec(
        color: charts.MaterialPalette.white,
      ),
      lineStyle: charts.LineStyleSpec(
        color: charts.MaterialPalette.white,
      ),
    );
  }

  static charts.RenderSpec<DateTime> axisThemeDateTime() {
    return const charts.GridlineRendererSpec(
      labelStyle: charts.TextStyleSpec(
        color: charts.MaterialPalette.white,
      ),
      lineStyle: charts.LineStyleSpec(
        color: charts.MaterialPalette.transparent,
      ),
    );
  }

  static charts.RenderSpec<String> axisThemeString() {
    return const charts.SmallTickRendererSpec(
      labelStyle: charts.TextStyleSpec(
        color: charts.MaterialPalette.white,
      ),
      lineStyle: charts.LineStyleSpec(
        color: charts.MaterialPalette.transparent,
      ),
    );
  }
}

class SimpleTimeSeriesChart extends StatelessWidget {
  final String title;
  final List<charts.Series<dynamic, DateTime>> seriesList;

  const SimpleTimeSeriesChart(this.title, this.seriesList, {super.key});

  factory SimpleTimeSeriesChart.fromLogs(String title, Logs logs) {
    return SimpleTimeSeriesChart(title, _createChartDataFromLogs(logs.logs));
  }

  @override
  Widget build(BuildContext context) {
    charts.RenderSpec<DateTime> renderSpecDomain =
        AxisTheme.axisThemeDateTime();

    return Scaffold(
        appBar: AppBar(
          title: const Text("Milou"),
        ),
        body: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: charts.TimeSeriesChart(
                defaultInteractions: true,
                seriesList,
                primaryMeasureAxis: charts.NumericAxisSpec(
                  renderSpec: AxisTheme.axisThemeNum(),
                ),
                domainAxis: charts.DateTimeAxisSpec(
                  renderSpec: renderSpecDomain,
                ),
                animate: true,
                dateTimeFactory: const charts.LocalDateTimeFactory(),
                behaviors: [
                  charts.ChartTitle(title,
                      behaviorPosition: charts.BehaviorPosition.top),
                ],
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
      List<int> logs) {
    final Map counts = {};
    Duration day = const Duration(days: 1);
    DateTime today = DateTime.now();
    for (int i = 0; i < 7; i += 1) {
      DateTime t = DateTime(today.year, today.month, today.day);
      counts[t] = 0;
      today = today.subtract(day);
    }

    for (var i in logs) {
      DateTime d = DateTime.fromMillisecondsSinceEpoch(i);
      DateTime t = DateTime(d.year, d.month, d.day);
      if (counts.containsKey(t)) {
        counts[t] += 1;
      } else {
        counts[t] = 1;
      }
    }

    final List<TimeSeriesData> data = [];

    List keys = counts.keys.toList();
    keys.sort(((a, b) => a.compareTo(b)));

    for (var key in keys) {
      data.add(TimeSeriesData(key, counts[key]));
    }

    return [
      charts.Series<TimeSeriesData, DateTime>(
        id: 'Training Logs',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesData series, _) => series.time,
        measureFn: (TimeSeriesData series, _) => series.cnt,
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
