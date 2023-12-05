import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeClass {
  static const Color lightPrimaryColor = Color(0xFFE5E5E5);
  static const Color darkPrimaryColor = Color(0xFF121212);
  static const Color secondaryColor = Color(0xFFE5E5E5);
  static const Color accentColor = Color(0xFFE5E5E5);

  static ThemeData get lightTheme => ThemeData(
        primaryColor: lightPrimaryColor,
        colorScheme: const ColorScheme.light().copyWith(
          primary: lightPrimaryColor,
          secondary: secondaryColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightPrimaryColor,
          foregroundColor: Colors.black,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentColor,
        ),
        textTheme: GoogleFonts.sourceSans3TextTheme(),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );

  static ThemeData get darkTheme => ThemeData(
        primaryColor: darkPrimaryColor,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: darkPrimaryColor,
          secondary: secondaryColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkPrimaryColor,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentColor,
        ),
        textTheme: GoogleFonts.sourceSans3TextTheme(),
      );
}
