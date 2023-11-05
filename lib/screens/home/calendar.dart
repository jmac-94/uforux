import 'package:flutter/material.dart';

import 'package:uforuxpi3/models/app_user.dart';

class Calendar extends StatefulWidget {
  final AppUser? user;

  const Calendar({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  String userId = '';

  @override
  void initState() {
    super.initState();

    userId = widget.user!.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
      ),
    );
  }
}
