import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uforuxpi3/app/models/app_user.dart';
import 'package:uforuxpi3/app/models/forum.dart';
import 'package:uforuxpi3/core/utils/dprint.dart';

class AppUserController {
  final String uid;
  AppUser? appUser;
  final CollectionReference studentCollection =
      FirebaseFirestore.instance.collection('students');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  AppUserController({required this.uid});

  Future<AppUser?> getUserData() async {
    final snapshot = await studentCollection.doc(uid).get();

    AppUser? user;
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      data['id'] = snapshot.id;
      user = AppUser.fromJson(data);
    }

    return user;
  }

  Future<void> updateStudentData({
    String? username,
    String? entrySemester,
    bool? assesor,
    String? degree,
    double? score,
    List<String>? followedForums,
  }) async {
    Map<String, dynamic> studentData = {
      if (username != null) 'username': username,
      if (entrySemester != null) 'entrySemester': entrySemester,
      if (assesor != null) 'assesor': assesor,
      if (degree != null) 'degree': degree,
      if (score != null) 'score': score,
      if (followedForums != null) 'followedForums': followedForums,
    };

    return await studentCollection
        .doc(uid)
        .set(studentData, SetOptions(merge: true));
  }

  Future<List<Forum>> fetchFollowedForums() async {
    List<Forum> followedForums = [];

    appUser = await getUserData();
    List<String>? followedForumsIds = appUser?.followedForums;

    if (followedForumsIds != null) {
      for (var i = 0; i < followedForumsIds.length; i++) {
        DocumentSnapshot<Map<String, dynamic>> docSnapshot = await firestore
            .collection('forums')
            .doc(followedForumsIds[i])
            .get();
        final Map<String, dynamic>? data = docSnapshot.data();
        data?['id'] = docSnapshot.id;

        if (data != null) {
          final Forum forum = Forum.fromJson(data);
          followedForums.add(forum);
        }
      }
    }

    return followedForums;
  }
}
