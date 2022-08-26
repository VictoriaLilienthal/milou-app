class Skill {
  String name;
  int cnt;
  bool mastered;
  int lastActivity;
  int todayCnt;
  int order;
  int creationTime;
  bool isDeleted;

  Skill(this.name,
      [this.cnt = 0,
      this.mastered = false,
      this.todayCnt = 0,
      this.lastActivity = 0,
      this.order = 0,
      this.creationTime = 0,
      this.isDeleted = false]);

  Map<String, dynamic> toJson() => {
        'name': name,
        'cnt': cnt,
        'mastered': mastered,
        'lastActivity': lastActivity,
        'todayCnt': todayCnt,
        'order': order,
        'isDeleted': isDeleted,
        'creationTime': creationTime
      };

  Skill.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        cnt = json['cnt'] ?? 0,
        mastered = json['mastered'] ?? false,
        todayCnt = json['todayCnt'] ?? 0,
        lastActivity = json['lastActivity'] ?? 0,
        order = json['order'] ?? 0,
        isDeleted = json['isDeleted'] ?? false,
        creationTime = json['creationTime'] ?? 0;
}
