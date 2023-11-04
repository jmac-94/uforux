import 'package:uforuxpi3/services/database.dart';

class AppUser {
  final String uid;
  Map<String, dynamic>? data;

  AppUser({required this.uid});

  Future<void> loadData() async {
    data = await DatabaseService(uid: uid).getUserData();
  }
}
