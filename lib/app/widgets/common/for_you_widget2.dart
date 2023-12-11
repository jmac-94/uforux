import 'package:flutter/material.dart';
import 'package:uforuxpi3/app/controllers/app_user_controller.dart';
import 'package:uforuxpi3/app/controllers/forum_controller.dart';
import 'package:uforuxpi3/app/models/app_user.dart';
import 'package:uforuxpi3/app/models/comment.dart';
import 'package:uforuxpi3/app/models/forum.dart';
import 'package:uforuxpi3/app/widgets/common/forum_comments_widget.dart';
import 'package:uforuxpi3/app/widgets/home/body_data.dart';
import 'package:uforuxpi3/app/widgets/home/forum_header.dart';
import 'package:uforuxpi3/app/widgets/common/icons_actions.dart';
import 'package:faker/faker.dart';
import 'package:uforuxpi3/core/utils/dprint.dart';

class ForYouWidget2 extends StatefulWidget {
  final String loggedUserId;

  const ForYouWidget2({
    super.key,
    required this.loggedUserId,
  });

  @override
  State<ForYouWidget2> createState() => _ForYouWidget2State();
}

class _ForYouWidget2State extends State<ForYouWidget2> {
  late AppUserController appUserController;
  List<ForumCommentsWidget> forumCommentsWidgets = [];

  @override
  void initState() {
    super.initState();

    appUserController = AppUserController(uid: widget.loggedUserId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Forum>>(
        future: appUserController.fetchFollowedForums(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Forum> followedForums = snapshot.data ?? [];

            List<Widget> forumCommentsWidgets = followedForums
                .where((forum) => forum.name != null)
                .map((forum) {
              return ForumCommentsWidget(
                loggedUserId: widget.loggedUserId,
                title: forum.name!,
              );
            }).toList();

            return ListView.builder(
              itemCount: forumCommentsWidgets.length,
              itemBuilder: (context, index) {
                return forumCommentsWidgets[index];
              },
            );
          }
        });
  }
}
