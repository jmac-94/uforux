import 'package:flutter/material.dart';
import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/widgets/icon_badge.dart';
import 'package:uforuxpi3/screens/home/calendar.dart';
import 'package:uforuxpi3/screens/home/home.dart';
import 'package:uforuxpi3/screens/home/notifications.dart';
import 'package:uforuxpi3/screens/home/profile.dart';

class MainScreen extends StatefulWidget {
  final AppUser? user;

  const MainScreen({super.key, required this.user});

  @override
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
    final AppUser? user = widget.user;
    _screens = [
      Calendar(),
      Home(user: user),
      Notifications(),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Seguidores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Foros',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: IconBadge(icon: Icons.notifications),
            label: 'Notificaciones',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
            backgroundColor: Colors.black,
          ),
        ],
      ),
    );
  }
}
