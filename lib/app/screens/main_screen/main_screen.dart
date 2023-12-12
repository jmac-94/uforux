import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:forux/app/models/app_user.dart';
import 'package:forux/app/screens/main_screen/calendar.dart';
import 'package:forux/app/screens/main_screen/home.dart';
import 'package:forux/app/screens/main_screen/courses.dart';
import 'package:forux/app/screens/main_screen/profile.dart';

class MainScreen extends StatefulWidget {
  // El usuario nunca llega como null al MainScreen
  final AppUser user;
  const MainScreen({
    super.key,
    required this.user,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    final AppUser user = widget.user;

    _screens = [
      // Calendar(user: user),
      const Calendar(),
      Home(user: user),
      Courses(user: user),
      Profile(user: user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _screens.elementAt(_currentIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // set the color depends if the theme is dark or light
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 8,
            ),
            child: GNav(
              gap: 3,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[200]!,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: Icons.calendar_month,
                  text: 'Calendario',
                ),
                GButton(
                  icon: Icons.home,
                  text: 'Foro',
                ),
                GButton(
                  icon: Icons.book,
                  text: 'Cursos',
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Perfil',
                ),
              ],
              selectedIndex: _currentIndex,
              onTabChange: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
