class Comment {
  int time;
  String comment;
  String skillName;
  bool isDeleted;
  int creationTime;

  Comment(
    this.comment,
    this.time, {
    this.skillName = "",
    this.creationTime = 0,
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() => {
        'time': time,
        'comment': comment,
        'skillName': skillName,
        'isDeleted': isDeleted,
        'creationTime': creationTime
      };

  Comment.fromJson(Map<String, dynamic> json)
      : time = json['time'],
        comment = json['comment'],
        skillName = json['skillName'] ?? '',
        isDeleted = json['isDeleted'] ?? false,
        creationTime = json['creationTime'] ?? 0;
}
