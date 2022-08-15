import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DB {
  Function pre = () => {};
  Function post = () => {};

  Future saveSkills(List<Skill> rowState) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      CollectionReference skillsCollection =
          FirebaseFirestore.instance.collection('user/$uid/skills');

      final skillBatch = FirebaseFirestore.instance.batch();

      for (int i = 0; i < rowState.length; i++) {
        Skill s = rowState[i];
        s.order = i;
        skillBatch.set(skillsCollection.doc(s.name), s.toJson());
      }

      pre();
      return skillBatch.commit().then((value) {
        post();
        return value;
      }, onError: (e) => post());
    }
  }

  Future<void> syncOrder(List<Skill> rowState) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      CollectionReference skillsCollection =
          FirebaseFirestore.instance.collection('user/$uid/skills');

      final skillBatch = FirebaseFirestore.instance.batch();

      for (int i = 0; i < rowState.length; i++) {
        Skill s = rowState[i];
        s.order = i;
        skillBatch.update(skillsCollection.doc(s.name), {'order': i});
      }
      pre();
      return skillBatch
          .commit()
          .then((value) => {post()}, onError: (e) => post());
    }
  }

  Future<Logs> getLogsForSkill(String task) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;

      CollectionReference logs = FirebaseFirestore.instance
          .collection('user/$uid/logs')
          .withConverter<Logs>(
              fromFirestore: (snapshot, _) => Logs.fromJson(snapshot.data()!),
              toFirestore: (logs, _) => logs.toJson());
      pre();
      Object? data = await logs.doc(task).get().then((value) {
        post();
        return value.data();
      }, onError: (e) => {post()});
      return data as Logs;
    } else {
      throw Exception("User logged out");
    }
  }

  Future<Iterable<Skill>> getAllSkills() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      CollectionReference skillsCollection = FirebaseFirestore.instance
          .collection('user/$uid/skills')
          .withConverter(
              fromFirestore: (snapshot, _) => Skill.fromJson(snapshot.data()!),
              toFirestore: (s, _) => (s as Skill).toJson());

      final docSnap = await skillsCollection.get();
      return docSnap.docs.map((e) => e.data() as Skill);
    } else {
      throw Exception("User logged out");
    }
  }

  Future addNewSkill(Skill s) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      DocumentReference skillsCollection =
          FirebaseFirestore.instance.collection('user/$uid/skills').doc(s.name);

      DocumentReference logsCollection =
          FirebaseFirestore.instance.collection('user/$uid/logs').doc(s.name);

      return FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(skillsCollection, s.toJson());
        transaction.set(logsCollection, Logs().toJson());
      }).then((value) => post(), onError: (e) => post());
    } else {
      throw Exception("User logged out");
    }
  }

  Future updateSkill(Skill s) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      DocumentReference skillsCollection =
          FirebaseFirestore.instance.collection('user/$uid/skills').doc(s.name);
      return skillsCollection.update(s.toJson()).then((value) {
        post();
        return value;
      }, onError: (e) => {post()});
    } else {
      throw Exception("User logged out");
    }
  }

  Future addClick(String name) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      DocumentReference skillDoc =
          FirebaseFirestore.instance.collection('user/$uid/skills').doc(name);

      DocumentReference skillLogsDoc =
          FirebaseFirestore.instance.collection('user/$uid/logs').doc(name);

      return FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(skillDoc, {
          'cnt': FieldValue.increment(1),
          'todayCnt': FieldValue.increment(1),
          'lastActivity': DateTime.now().millisecondsSinceEpoch
        });
        transaction.update(skillLogsDoc, {
          'logs': FieldValue.arrayUnion([DateTime.now().millisecondsSinceEpoch])
        });
      });
    } else {
      throw Exception("User logged out");
    }
  }

  Future delete(String name) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      DocumentReference skillDoc =
          FirebaseFirestore.instance.collection('user/$uid/skills').doc(name);

      DocumentReference skillLogsDoc =
          FirebaseFirestore.instance.collection('user/$uid/logs').doc(name);
      pre();
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.delete(skillDoc);
        transaction.delete(skillLogsDoc);
      }).then((value) => post(), onError: (e) => post());
    } else {
      throw Exception("User logged out");
    }
  }
}

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

  factory Logs.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    Logs l = Logs();

    l.logs = (data?['logs'] as List<dynamic>).map((e) => e as int).toList();
    return l;
  }

  Map<String, Object?> toFirestore() {
    return toJson();
  }
}

class Goal {
  String name;
  double target;
  Goal(this.name, [this.target = 60]);
}
