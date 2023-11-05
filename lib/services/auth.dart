import 'package:firebase_auth/firebase_auth.dart';

import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/services/database.dart';
import 'package:uforuxpi3/util/dprint.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Change from FirebaseUser to AppUser
  AppUser? _userFromFirebaseUser(User? user) {
    return user == null ? null : AppUser(id: user.uid);
  }

  Stream<AppUser?> get user {
    Stream<User?> streamUser = _auth.authStateChanges();
    return streamUser.map(_userFromFirebaseUser);
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      User? user = result.user;

      return _userFromFirebaseUser(user);
    } catch (e) {
      dPrint(e.toString());
    }
  }

  Future registerWithEmailAndPassword({
    required String email,
    required String username,
    required String password,
    required String entrySemester,
    required bool assesor,
    required String degree,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = result.user;

      // Create a new doc for the user with the uid
      await DatabaseService(uid: user!.uid).updateStudentData(
          username: username,
          entrySemester: entrySemester,
          assesor: assesor,
          degree: degree,
          score: 0.0,
          forums: []);

      return _userFromFirebaseUser(user);
    } catch (e) {
      dPrint(e.toString());
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      dPrint(e.toString());
      return null;
    }
  }
}
