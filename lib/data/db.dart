import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:milou_app/data/logs.dart';

import 'comment.dart';
import 'dog_profile.dart';
import 'goal.dart';
import 'skill.dart';

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

  Future deleteSkill(String name) async {
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

  Future addNewGoal(Goal g) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      DocumentReference goalDoc =
          FirebaseFirestore.instance.collection('user/$uid/goals').doc(g.name);

      pre();
      goalDoc.set(g.toJson()).then((value) {
        post();
        return value;
      }, onError: (e) => post());
    } else {
      throw Exception("User logged out");
    }
  }

  Future deleteGoal(Goal g) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      DocumentReference goalDoc =
          FirebaseFirestore.instance.collection('user/$uid/goals').doc(g.name);

      pre();
      goalDoc.delete().then((value) {
        post();
        return value;
      }, onError: (e) => post());
    } else {
      throw Exception("User logged out");
    }
  }

  Future<Iterable<Goal>> getAllGoals() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      CollectionReference goalsCollection = FirebaseFirestore.instance
          .collection('user/$uid/goals')
          .withConverter(
              fromFirestore: (snapshot, _) => Goal.fromJson(snapshot.data()!),
              toFirestore: (s, _) => (s as Goal).toJson());

      final goalSnapshot = await goalsCollection.get();
      return goalSnapshot.docs.map((e) => e.data() as Goal);
    } else {
      throw Exception("User logged out");
    }
  }

  Future addNewComment(Comment g) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      DocumentReference goalDoc = FirebaseFirestore.instance
          .collection('user/$uid/comments')
          .doc("${g.creationTime}");

      pre();
      goalDoc.set(g.toJson()).then((value) {
        post();
        return value;
      }, onError: (e) => post());
    } else {
      throw Exception("User logged out");
    }
  }

  Future<Iterable<Comment>> getAllComments() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      CollectionReference commentCollection = FirebaseFirestore.instance
          .collection('user/$uid/comments')
          .withConverter(
              fromFirestore: (snapshot, _) =>
                  Comment.fromJson(snapshot.data()!),
              toFirestore: (s, _) => (s as Comment).toJson());

      final goalSnapshot = await commentCollection.get();
      return goalSnapshot.docs.map((e) => e.data() as Comment);
    } else {
      throw Exception("User logged out");
    }
  }

  Future addNewDog(DogProfile dog) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      DocumentReference dogDoc = FirebaseFirestore.instance
          .collection('user/$uid/dogs')
          .doc("${dog.creationTime}");

      pre();
      dogDoc.set(dog.toJson()).then((value) {
        post();
        return value;
      }, onError: (e) => post());
    } else {
      throw Exception("User logged out");
    }
  }

  Future<Iterable<DogProfile>> getAllDogs() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      CollectionReference commentCollection = FirebaseFirestore.instance
          .collection('user/$uid/dogs')
          .withConverter(
              fromFirestore: (snapshot, _) =>
                  DogProfile.fromJson(snapshot.data()!),
              toFirestore: (s, _) => (s as DogProfile).toJson());

      final goalSnapshot = await commentCollection.get();
      return goalSnapshot.docs.map((e) => e.data() as DogProfile);
    } else {
      throw Exception("User logged out");
    }
  }
}
