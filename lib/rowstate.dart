import 'package:tuple/tuple.dart';
import 'dart:convert';

class RowState {
  String name;
  int cnt;
  List<Tuple2<bool, int>> logs;

  RowState(this.name, [this.cnt=0, this.logs=const []] );

  Map<String, dynamic> toJson() => {
        'name': name,
        'cnt': cnt,
        'logs': toJsonFromTupleList(logs),
      };

  RowState.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        cnt = json['cnt'],
        logs = fromJsonToTupleList(json['logs']);
}

List<Tuple2<bool, int>> fromJsonToTupleList(String json) {
  Iterable iterable = jsonDecode(json);

  List newList = iterable.toList();

  final newTuples = newList
      .map(
        (e) => Tuple2<bool, int>(
          e['1'],
          e['2'],
        ),
      )
      .toList();
  return newTuples;
}

String toJsonFromTupleList(List<Tuple2> tuples) {
  List list = tuples
      .map(
        (e) => {
          '1': e.item1,
          '2': e.item2,
        },
      )
      .toList();

  String json = jsonEncode(list);
  return json;
}
