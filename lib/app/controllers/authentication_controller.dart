import 'package:firebase_auth/firebase_auth.dart';

import 'package:forux/app/models/app_user.dart';
import 'package:forux/core/utils/dprint.dart';
import 'package:forux/app/controllers/app_user_controller.dart';

class AuthenticationController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<AppUser?> get user {
    final Stream<User?> streamUser = _auth.authStateChanges();
    return streamUser.asyncMap(_appUserFromFirebaseUser);
  }

  Future<AppUser?> _appUserFromFirebaseUser(User? user) async {
    if (user == null) {
      return null;
    } else {
      final appUserController = AppUserController(uid: user.uid);
      final AppUser? appUser = await appUserController.user;
      return appUser;
    }
  }

  Future<AppUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;

      return _appUserFromFirebaseUser(user);
    } catch (e) {
      dPrint(e);
      return null;
    }
  }

  Future<AppUser?> registerWithEmailAndPassword({
    required String email,
    required String username,
    required String password,
    required String entrySemester,
    required bool assesor,
    required String degree,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final User? user = result.user;

      if (user != null) {
        await AppUserController(uid: user.uid).updateStudentData(
          username: username,
          entrySemester: entrySemester,
          assesor: assesor,
          degree: degree,
          score: 0.0,
          followedForums: [],
          aboutMe: '',
          comments: {},
        );
      }

      return _appUserFromFirebaseUser(user);
    } catch (e) {
      dPrint(e);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      dPrint(e);
    }
  }
}
