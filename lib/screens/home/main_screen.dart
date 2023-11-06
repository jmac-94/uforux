import 'package:flutter/material.dart';

import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/widgets/icon_badge.dart';
import 'package:uforuxpi3/screens/home/calendar.dart';
import 'package:uforuxpi3/screens/home/home.dart';
import 'package:uforuxpi3/screens/home/notifications.dart';
import 'package:uforuxpi3/screens/home/profile.dart';

class MainScreen extends StatefulWidget {
  // El usuario no llega como null al MainScreen
  final AppUser user;

  const MainScreen({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  late List<Widget> _screens;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Foros',
          ),
          BottomNavigationBarItem(
            icon: IconBadge(icon: Icons.notifications),
            label: 'Notificaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
