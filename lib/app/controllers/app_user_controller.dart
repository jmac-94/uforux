import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uforuxpi3/app/models/app_user.dart';

class AppUserController {
  final String uid;
  final CollectionReference studentCollection =
      FirebaseFirestore.instance.collection('students');

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
    List<String>? forums,
  }) async {
    Map<String, dynamic> studentData = {
      if (username != null) 'username': username,
      if (entrySemester != null) 'entrySemester': entrySemester,
      if (assesor != null) 'assesor': assesor,
      if (degree != null) 'degree': degree,
      if (score != null) 'score': score,
      if (forums != null) 'forums': forums,
    };

    return await studentCollection
        .doc(uid)
        .set(studentData, SetOptions(merge: true));
  }
}
