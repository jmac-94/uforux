import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forux/app/controllers/app_user_controller.dart';
import 'package:forux/app/controllers/forum_controller.dart';
import 'package:forux/app/controllers/profile_controller.dart';
import 'package:forux/app/models/app_user.dart';
import 'package:forux/app/models/comment.dart';
import 'package:forux/app/models/forum.dart';
import 'package:forux/app/widgets/profile/icons_actions_my_forum.dart';
import 'package:forux/app/widgets/home/body_data.dart';
import 'package:forux/app/widgets/home/forum_header.dart';
import 'package:forux/app/widgets/common/icons_actions.dart';
import 'package:faker/faker.dart';
import 'package:forux/core/structures/pair.dart';

class MyForumWidget extends StatefulWidget {
  final AppUser loggedUser;

  const MyForumWidget({
    super.key,
    required this.loggedUser,
  });

  @override
  State<MyForumWidget> createState() => _MyForumWidgetState();
}

class _MyForumWidgetState extends State<MyForumWidget> {
  final ScrollController _scrollController = ScrollController();
  late ProfileController profileController;
  bool isLoading = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();

    profileController = ProfileController(loggedUser: widget.loggedUser);

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        profileController.hasMoreData) {
      profileController.loadComments();
    }
  }

  String getUserProfilePhoto(Comment comment) {
    final profilePhoto =
        'https://random.imagecdn.app/500/${faker.randomGenerator.integer(1000)}';

    return profilePhoto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await profileController.loadComments(isRefresh: true);
          setState(() {});
        },
        child: FutureBuilder<void>(
          future: profileController.initialFetchDone
              ? null
              : profileController.loadComments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !profileController.initialFetchDone) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return ListView.separated(
                controller: _scrollController,
                itemCount: profileController.hasMoreData
                    ? profileController.loggedUser.comments!.length + 1
                    : profileController.loggedUser.comments!.length,
                itemBuilder: (context, index) {
                  if (index == profileController.loggedUser.comments!.length) {
                    if (profileController.hasMoreData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return Container();
                    }
                  }

                  // Get current comment from index
                  final List<Comment> commentsList =
                      profileController.loggedUser.comments!.values.toList();
                  final Comment comment = commentsList[index];

                  // Get current comment properties
                  final String profilePhoto = getUserProfilePhoto(comment);

                  // Get current comment author username
                  comment.author = profileController.loggedUser;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 5.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Hero(
                        tag: 'CommentsForum${comment.id}',
                        child: Column(
                          children: [
                            const SizedBox(height: 5),
                            ForumHeader(
                              comment: comment,
                            ),
                            const SizedBox(height: 5),
                            BodyData(
                              comment: comment,
                            ),
                            if (comment.attachments['images'] == null)
                              const SizedBox(
                                height: 20,
                              ),
                            IconsActionsMyForum(
                              comment: comment,
                              profileController: profileController,
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    Container(),
              );
            }
          },
        ),
      ),
    );
  }
}
