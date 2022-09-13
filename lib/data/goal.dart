class Goal {
  String name;
  int target;
  bool isDeleted;
  int type;
  bool isRecurring;
  int creationTime;
  Goal(this.name, this.target, this.type, this.isRecurring, this.creationTime,
      this.isDeleted);

  Map<String, dynamic> toJson() => {
        'name': name,
        'target': target,
        'type': type,
        'isDeleted': isDeleted,
        'recurring': isRecurring,
        'creationTime': creationTime
      };

  Goal.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        target = json['target'] ?? 60,
        type = json['type'] ?? 0,
        isDeleted = json['isDeleted'] ?? false,
        isRecurring = json['recurring'] ?? false,
        creationTime = json['creationTime'] ?? 0;

  bool isActive() {
    int inDays = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(creationTime))
        .inDays;

    if (isRecurring) {
      return true;
    } else {
      if (type == 0 && inDays != 0) {
        return false;
      } else if (inDays > 7) {
        return false;
      }

      return true;
    }
  }
}
