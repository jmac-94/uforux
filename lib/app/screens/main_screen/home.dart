import 'package:flutter/material.dart';

import 'package:uforuxpi3/app/models/app_user.dart';
import 'package:uforuxpi3/app/widgets/common/forum_comments_widget.dart';

class Home extends StatefulWidget {
  final AppUser user;

  const Home({
    super.key,
    required this.user,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.grey[100],
        ),
        Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AppBar(
              title: const Text('Foro general'),
              titleTextStyle: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.notifications),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade900,
                      Colors.blue.shade700,
                    ],
                  ),
                ),
              ),
              shadowColor: Colors.transparent,
            ),
          ),
          backgroundColor: Colors.grey[100],
          body: ForumCommentsWidget(
            loggedUserId: widget.user.id,
            title: 'general',
          ),
        ),
      ],
    );
  }
}
