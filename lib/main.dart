import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/utils/const.dart';
import 'core/firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Idioma español
  initializeDateFormatting('es_MX', null);
  timeago.setLocaleMessages('es', timeago.EsMessages());

  if (Platform.isIOS) {
    await Firebase.initializeApp(
      name: Constants.firebaseAppName,
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}
