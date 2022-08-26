class Goal {
  String name;
  int target;
  bool isDeleted;
  int type;
  int creationTime;
  Goal(this.name,
      [this.target = 60,
      this.isDeleted = false,
      this.type = 0,
      this.creationTime = 0]);

  Map<String, dynamic> toJson() => {
        'name': name,
        'target': target,
        'type': type,
        'isDeleted': isDeleted,
        'creationTime': creationTime
      };

  Goal.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        target = json['target'] ?? 60,
        type = json['type'] ?? 0,
        isDeleted = json['isDeleted'] ?? false,
        creationTime = json['creationTime'] ?? 0;
}
