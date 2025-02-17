import 'package:flutter/material.dart';
import 'package:forux/app/controllers/app_user_controller.dart';

import 'package:forux/app/widgets/common/forum_comments_widget.dart';
import 'package:forux/app/widgets/common/teacher_comments_widget.dart';
import 'package:forux/app/widgets/courses/wikipedia.dart';

class ForumView extends StatefulWidget {
  final String loggedUserId;
  final String title;

  const ForumView({
    super.key,
    required this.loggedUserId,
    required this.title,
  });

  @override
  State<ForumView> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<ForumView> {
  late AppUserController appUserController;
  bool isFollowed = false;

  @override
  void initState() {
    super.initState();

    appUserController = AppUserController(uid: widget.loggedUserId);
  }

  Future<bool> fetchForumFollowedStatus() async {
    bool forumFollowedStatus =
        await appUserController.hasUserFollowedForum(widget.title);

    return forumFollowedStatus;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          leading: const BackButton(color: Colors.black),
          // TODO: Implementar la funcionalidad de búsqueda
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.search, color: Colors.black),
          //     onPressed: () {},
          //   ),
          //   IconButton(
          //     icon: const Icon(Icons.more_horiz_outlined, color: Colors.black),
          //     onPressed: () {},
          //   ),
          // ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                widget.title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 25.0,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Aquí se explica un poco de lo que va el curso y qué se puede encontrar en el mismo.',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FutureBuilder<bool>(
                future: fetchForumFollowedStatus(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Muestra un indicador de carga
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); // Maneja el error
                  } else {
                    bool isFollowed = snapshot.data ?? false;

                    return TextButton(
                      onPressed: () async {
                        bool newFollowStatus = !isFollowed;
                        await appUserController.updateFollowedForums(
                            widget.title, newFollowStatus);
                        setState(() {});
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(isFollowed ? 'Seguido' : 'Seguir'),
                    );
                  }
                },
              ),
            ),
            const TabBar(
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Foro'),
                Tab(text: 'Profesores'),
                Tab(text: 'Wikipedia'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ForumCommentsWidget(
                    loggedUserId: widget.loggedUserId,
                    title: widget.title,
                  ),
                  const TeacherCommentsWidget(),
                  Wikipedia(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
