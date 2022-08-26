class Logs {
  List<int> logs;

  Logs([this.logs = const []]);

  Map<String, dynamic> toJson() => {
        'logs': logs,
      };

  Logs.fromJson(Map<String, dynamic> json) : logs = tryParseLogs(json);

  static List<int> tryParseLogs(Map<String, dynamic> json) {
    try {
      return (json['logs'] as List<dynamic>).map((e) => e as int).toList();
    } catch (e) {
      return [];
    }
  }
}
