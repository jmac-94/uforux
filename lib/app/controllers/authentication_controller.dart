import 'package:firebase_auth/firebase_auth.dart';

import 'package:uforuxpi3/app/models/app_user.dart';
import 'package:uforuxpi3/core/utils/dprint.dart';
import 'package:uforuxpi3/app/controllers/app_user_controller.dart';

class AuthenticationController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppUser? _appUserFromFirebaseUser(User? user) {
    return user == null ? null : AppUser(id: user.uid);
  }

  Stream<AppUser?> get user {
    Stream<User?> streamUser = _auth.authStateChanges();
    return streamUser.map(_appUserFromFirebaseUser);
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      User? user = result.user;

      return _appUserFromFirebaseUser(user);
    } catch (e) {
      dPrint(e);
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

      if (user != null) {
        await AppUserController(uid: user.uid).updateStudentData(
            username: username,
            entrySemester: entrySemester,
            assesor: assesor,
            degree: degree,
            score: 0.0,
            forums: []);
      }

      return _appUserFromFirebaseUser(user);
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
