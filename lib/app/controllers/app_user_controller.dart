import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserController {
  final String uid;

  AppUserController({required this.uid});

  final CollectionReference studentCollection =
      FirebaseFirestore.instance.collection('students');

  Future<Map<String, dynamic>> getUserData() async {
    final snapshot = await studentCollection.doc(uid).get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      data['id'] = snapshot.id; // Add the user's ID to the data
      return data;
    } else {
      return {};
    }
  }

  Future updateStudentData({
    required String username,
    required String entrySemester,
    required bool assesor,
    required String degree,
    required double score,
    required List<String> forums,
  }) async {
    Map<String, dynamic> studentData = {
      'username': username,
      'entrySemester': entrySemester,
      'assesor': assesor,
      'degree': degree,
      'score': score,
      'forums': forums,
    };

    return await studentCollection.doc(uid).set(studentData);
  }
}
