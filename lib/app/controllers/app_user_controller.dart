import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forux/app/models/app_user.dart';
import 'package:forux/app/models/forum.dart';
import 'package:forux/core/utils/dprint.dart';
import 'package:forux/core/utils/extensions.dart';

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

    // Inicializar el appUser solamente si no es nulo
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

  Future<bool> hasUserFollowedForum(String forumName) async {
    appUser = await getUserData();
    List<String>? followedForumsIds = appUser?.followedForums;

    if (followedForumsIds != null) {
      for (var i = 0; i < followedForumsIds.length; i++) {
        DocumentSnapshot<Map<String, dynamic>> docSnapshot = await firestore
            .collection('forums')
            .doc(followedForumsIds[i])
            .get();

        final Map<String, dynamic>? data = docSnapshot.data();

        if (data != null) {
          if (data['name'].removeAccentsAndToLowercase() ==
              forumName.removeAccentsAndToLowercase()) {
            return true;
          }
        }
      }
    }

    return false;
  }

  Future<void> updateFollowedForums(String forumName, bool isFollowed) async {
    appUser = await getUserData();
    List<String>? followedForumsIds = appUser?.followedForums ?? [];

    // Buscar el ID del foro a partir de su nombre
    final QuerySnapshot<Map<String, dynamic>> forumSnapshot = await firestore
        .collection('forums')
        .where('name', isEqualTo: forumName.removeAccentsAndToLowercase())
        .get();
    final DocumentSnapshot<Map<String, dynamic>> forumDoc =
        forumSnapshot.docs.first;
    final String forumId = forumDoc.id;

    if (isFollowed) {
      if (!followedForumsIds.contains(forumId)) {
        followedForumsIds.add(forumId);
      }
    } else {
      followedForumsIds.remove(forumId);
    }

    await firestore.collection('students').doc(appUser?.id).update({
      'followedForums': followedForumsIds,
    });
  }
}
