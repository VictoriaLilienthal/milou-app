import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DB {
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
      return skillBatch.commit();
    }
  }

  Future syncOrder(List<Skill> rowState) async {
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

      return skillBatch.commit();
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

      return (await logs.doc(task).get()).data() as Logs;
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
              fromFirestore: Skill.fromFirestore,
              toFirestore: (Object? s, options) => (s as Skill).toFirestore());

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
      });
    } else {
      throw Exception("User logged out");
    }
  }

  void saveSkill(Skill s, Logs l) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      DocumentReference skillsCollection =
          FirebaseFirestore.instance.collection('user/$uid/skills').doc(s.name);

      DocumentReference logsCollection =
          FirebaseFirestore.instance.collection('user/$uid/logs').doc(s.name);

      skillsCollection.update(s.toJson());
      logsCollection.update(s.toJson());
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
      return skillsCollection.update(s.toJson());
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

  // void syncStorage(List<RowState> rowState) async {
  //   final currentUser = FirebaseAuth.instance.currentUser;
  //
  //   if (currentUser != null) {
  //     String uid = currentUser.uid;
  //     CollectionReference skillsCollection =
  //         FirebaseFirestore.instance.collection('user/$uid/skills');
  //
  //     CollectionReference logsCollection =
  //         FirebaseFirestore.instance.collection('user/$uid/logs');
  //
  //     final skillBatch = FirebaseFirestore.instance.batch();
  //     final logsBatch = FirebaseFirestore.instance.batch();
  //
  //     for (int i = 0; i < rowState.length; i++) {
  //       final RowState state = rowState[i];
  //       Skill s = Skill(state.name);
  //       s.cnt = state.cnt;
  //       s.todayCnt = 0;
  //       s.cnt = state.logs.length;
  //       s.order = i;
  //
  //       Logs l = Logs();
  //       l.logs = state.logs.map((e) => e.item2).toList();
  //
  //       skillBatch.set(skillsCollection.doc(s.name), s.toJson());
  //       logsBatch.set(logsCollection.doc(s.name), l.toJson());
  //     }
  //
  //     skillBatch.commit();
  //     logsBatch.commit();
  //   }
  // }

  Future delete(String name) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      DocumentReference skillDoc =
          FirebaseFirestore.instance.collection('user/$uid/skills').doc(name);

      DocumentReference skillLogsDoc =
          FirebaseFirestore.instance.collection('user/$uid/logs').doc(name);

      return FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.delete(skillDoc);
        transaction.delete(skillLogsDoc);
      });
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

  Skill(this.name,
      [this.cnt = 0,
      this.mastered = false,
      this.todayCnt = 0,
      this.lastActivity = 0,
      this.order = 0]);

  Map<String, dynamic> toJson() => {
        'name': name,
        'cnt': cnt,
        'mastered': mastered,
        'lastActivity': lastActivity,
        'todayCnt': todayCnt,
        'order': order
      };

  Skill.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        cnt = json['cnt'],
        mastered = json['mastered'],
        todayCnt = json['todayCnt'],
        lastActivity = json['lastActivity'],
        order = json['order'];

  factory Skill.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    Skill s = Skill(data?['name']);

    s.cnt = data?['cnt'];
    s.mastered = data?['mastered'];
    s.lastActivity = data?['lastActivity'];
    s.todayCnt = data?['todayCnt'];
    s.order = data?['order'];

    return s;
  }

  Map<String, Object?> toFirestore() {
    return {
      'name': name,
      'cnt': cnt,
      'mastered': mastered,
      'today': lastActivity,
      'todayCnt': todayCnt,
      'order': order
    };
  }
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
      print("Invalid logs value ${json['logs']}");
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
    return {
      'logs': logs,
    };
  }
}
