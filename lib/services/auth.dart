import 'dart:developer';

import 'package:uforuxpi3/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uforuxpi3/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Change from FirebaseUser to AppUser
  AppUser? _userFromFirebaseUser(User? user) {
    if (user != null) {
      return AppUser(uid: user.uid);
    }
    return null;
  }

  // Get stream of AppUser
  Stream<AppUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
    // .map((User? user) => _userFromFirebaseUser(user));
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      User? user = result.user;

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
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
      print(e.toString());
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
