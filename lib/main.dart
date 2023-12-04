import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'core/firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS) {
    await Firebase.initializeApp(
      name: 'uforux-pi3',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}
