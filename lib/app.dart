import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/services/auth.dart';
import 'package:uforuxpi3/theme_class.dart';
import 'package:uforuxpi3/util/const.dart';
import 'package:uforuxpi3/screens/wrapper.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<AppUser?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: Constants.appName,
        theme: ThemeClass.lighTheme,
        darkTheme: ThemeClass.darkTheme,
        themeMode: ThemeMode.light,
        home: const Wrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  ThemeData themeData(ThemeData theme) {
    return theme.copyWith(
      textTheme: GoogleFonts.sourceSans3TextTheme(
        theme.textTheme,
      ),
    );
  }
}
