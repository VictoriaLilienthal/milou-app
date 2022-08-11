class Skill {
  String name;
  int cnt;
  bool mastered;
  String today;
  int todayCnt;

  Skill(this.name,
      [this.cnt = 0,
      this.mastered = false,
      this.todayCnt = 0,
      this.today = ""]);

  Map<String, dynamic> toJson() => {
        'name': name,
        'cnt': cnt,
        'mastered': mastered,
        'today': today,
        'todayCnt': todayCnt
      };

  Skill.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        cnt = json['cnt'],
        mastered = json['mastered'],
        todayCnt = json['todayCnt'],
        today = json['today'];
}
