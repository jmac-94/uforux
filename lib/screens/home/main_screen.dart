import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/screens/home/calendar.dart';
import 'package:uforuxpi3/screens/home/home.dart';
import 'package:uforuxpi3/screens/home/notifications.dart';
import 'package:uforuxpi3/screens/home/profile.dart';

class MainScreen extends StatefulWidget {
  // El usuario no llega como null al MainScreen
  final AppUser user;
  const MainScreen({
    super.key,
    required this.user,
  });
  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    final AppUser user = widget.user;

    _screens = [
      Calendar(user: user),
      Home(user: user),
      Notifications(user: user),
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
                  text: 'Calendar',
                ),
                GButton(
                  icon: Icons.home,
                  text: 'Forum',
                ),
                GButton(
                  icon: Icons.book,
                  text: 'Books',
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Profile',
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
