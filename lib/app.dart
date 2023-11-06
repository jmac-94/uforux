import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/services/auth.dart';
import 'package:uforuxpi3/util/const.dart';
import 'package:uforuxpi3/util/theme_config.dart';
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

class ThemeClass {
  Color lightprimaryColor = const Color(0xFFE5E5E5);
  Color darkprimaryColor = const Color(0xFF121212);
  Color secondaryColor = const Color(0xFFE5E5E5);
  Color accentColor = const Color(0xFFE5E5E5);

  static ThemeData lighTheme = ThemeData(
    primaryColor: ThemeData.light().scaffoldBackgroundColor,
    colorScheme: const ColorScheme.light().copyWith(
      primary: _themeClass.lightprimaryColor,
      secondary: _themeClass.secondaryColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ThemeData.light().scaffoldBackgroundColor,
      foregroundColor: Colors.black,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blueAccent,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: ThemeData.dark().primaryColor,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.red,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ThemeData.dark().primaryColor,
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: ThemeData.dark().primaryColor,
      secondary: ThemeData.dark().secondaryHeaderColor,
    ),
  );
}

ThemeClass _themeClass = ThemeClass();
