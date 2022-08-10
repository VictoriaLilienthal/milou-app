import 'package:tuple/tuple.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class RowState {
  String name;
  int cnt;
  List<Tuple2<bool, int>> logs;
  String id;
  bool mastered;

  RowState(this.id, this.name,
      [this.cnt = 0, this.logs = const [], this.mastered = false]);

  static bool isJSStr(Map<String, dynamic> json) {
    if (!json.containsKey('id')) {
      return false;
    }
    try {
      dynamic val = json['id'];
      String s = val;
    } catch (e) {
      return false;
    }
    return true;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cnt': cnt,
        'logs': toJsonFromTupleList(logs),
        'mastered': mastered,
      };

  RowState.fromJson(Map<String, dynamic> json)
      : id = isJSStr(json) ? json['id'] : const Uuid().v4(),
        name = json['name'],
        cnt = json['cnt'],
        mastered = json.containsKey('mastered') ? json['mastered'] : false,
        logs = fromJsonToTupleList(
          json['logs'],
        );
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
