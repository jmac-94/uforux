import 'package:flutter/material.dart';

import 'package:uforuxpi3/models/app_user.dart';

class Books extends StatefulWidget {
  final AppUser? user;

  const Books({super.key, required this.user});

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  String userId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Libros",
        ),
      ),
    );
  }
}
