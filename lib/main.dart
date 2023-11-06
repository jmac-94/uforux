import 'app.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'uforux-pi3',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
  