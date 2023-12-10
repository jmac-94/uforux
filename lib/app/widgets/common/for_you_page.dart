import 'package:flutter/material.dart';
import 'package:uforuxpi3/app/controllers/app_user_controller.dart';
import 'package:uforuxpi3/app/controllers/forum_controller.dart';
import 'package:uforuxpi3/app/models/app_user.dart';
import 'package:uforuxpi3/app/models/comment.dart';
import 'package:uforuxpi3/app/models/forum.dart';
import 'package:uforuxpi3/app/widgets/home/body_data.dart';
import 'package:uforuxpi3/app/widgets/home/forum_header.dart';
import 'package:uforuxpi3/app/widgets/home/icons_actions.dart';
import 'package:faker/faker.dart';

class ForYouWidget extends StatefulWidget {
  final String loggedUserId;

  const ForYouWidget({
    super.key,
    required this.loggedUserId,
  });

  @override
  State<ForYouWidget> createState() => _ForYouWidgetState();
}

class _ForYouWidgetState extends State<ForYouWidget> {
  final ScrollController _scrollController = ScrollController();
  late AppUserController appUserController;
  List<ForumController> forumsControllers = [];
  bool isLoading = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();

    appUserController = AppUserController(uid: widget.loggedUserId);

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      for (var forumController in forumsControllers) {
        if (forumController.hasMoreData) {
          forumController.loadComments();
        }
      }
    }
  }

  String getUserProfilePhoto(Comment comment) {
    final profilePhoto =
        'https://random.imagecdn.app/500/${faker.randomGenerator.integer(1000)}';

    return profilePhoto;
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

          forumsControllers = followedForums.map((forum) {
            return ForumController(
                forum: forum, loggedUserId: widget.loggedUserId);
          }).toList();

          return Scaffold(
            body: ListView.builder(
              itemCount: forumsControllers.length,
              itemBuilder: (context, forumIndex) {
                ForumController forumController = forumsControllers[forumIndex];

                return FutureBuilder<void>(
                  future: forumController.initialFetchDone
                      ? null
                      : forumController.loadComments(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !forumController.initialFetchDone) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: forumController.hasMoreData
                            ? forumController.forum.comments.length + 1
                            : forumController.forum.comments.length,
                        itemBuilder: (context, commentIndex) {
                          if (commentIndex ==
                              forumController.forum.comments.length) {
                            return forumController.hasMoreData
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Container();
                          }
                          final Comment comment = forumController
                              .forum.comments.values
                              .toList()[commentIndex];
                          final String profilePhoto =
                              getUserProfilePhoto(comment);

                          // Aquí utilizamos tu implementación de cómo se muestra cada comentario
                          return FutureBuilder<AppUser>(
                            future:
                                forumController.fetchAppUser(comment.userId),
                            builder: (BuildContext context,
                                AsyncSnapshot<AppUser> userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              } else if (userSnapshot.hasError) {
                                return Text('Error: ${userSnapshot.error}');
                              } else {
                                comment.author = userSnapshot.data;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6.0, horizontal: 5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: Hero(
                                      tag: 'CommentsForum${comment.id}',
                                      child: Column(
                                        children: [
                                          ForumHeader(
                                              profilePhoto: profilePhoto,
                                              comment: comment),
                                          const SizedBox(height: 5),
                                          BodyData(
                                              forumController: forumController,
                                              comment: comment),
                                          Container(
                                              width: double.infinity,
                                              height: 1.5,
                                              color: Colors.grey[200]),
                                          IconsActions(
                                              comment: comment,
                                              forumController: forumController),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(),
                      );
                    }
                  },
                );
              },
            ),
          );
        }
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return FutureBuilder<List<Forum>>(
  //     future: appUserController.fetchFollowedForums(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(child: CircularProgressIndicator());
  //       } else if (snapshot.hasError) {
  //         return Text('Error: ${snapshot.error}');
  //       } else {
  //         List<Forum> followedForums = snapshot.data ?? [];

  //         // Agregar un controlador para cada foro
  //         for (var followedForum in followedForums) {
  //           ForumController forumController = ForumController(
  //             forum: followedForum,
  //             loggedUserId: widget.loggedUserId,
  //           );

  //           forumsControllers.add(forumController);
  //         }

  //         // Inicializar cada controlador
  //         for (var i = 0; i < followedForums.length; i++) {
  //           forumsControllers[i].forum = followedForums[i];
  //         }

  //         return Scaffold(
  //           body: RefreshIndicator(
  //             onRefresh: () async {
  //               for (var forumController in forumsControllers) {
  //                 await forumController.loadComments();
  //               }
  //               setState(() {});
  //             },
  //             child:
  //           ),

  //           ListView.builder(
  //             controller: _scrollController,
  //             itemCount: forumsControllers.length,
  //             itemBuilder: (context, index) {
  //               ForumController forumController = forumsControllers[index];

  //               return FutureBuilder<void>(
  //                 future: forumController.initialFetchDone
  //                     ? null
  //                     : forumController.loadComments(),
  //                 builder: (context, snapshot) {
  //                   if (snapshot.connectionState == ConnectionState.waiting &&
  //                       !forumController.initialFetchDone) {
  //                     return const Center(
  //                       child: CircularProgressIndicator(),
  //                     );
  //                   } else if (snapshot.hasError) {
  //                     return Center(
  //                       child: Text('Error: ${snapshot.error}'),
  //                     );
  //                   } else {
  //                     if (forumsControllers.isNotEmpty) {
  //                       return ListView.builder(
  //                         itemCount: forumController.forum.comments.length,
  //                         itemBuilder: (context, commentIndex) {
  //                           final List<Comment> commentsList =
  //                               forumController.forum.comments.values.toList();
  //                           final Comment comment = commentsList[commentIndex];

  //                           final String profilePhoto =
  //                               getUserProfilePhoto(comment);

  //                           return FutureBuilder<AppUser>(
  //                             future:
  //                                 forumController.fetchAppUser(comment.userId),
  //                             builder: (BuildContext context,
  //                                 AsyncSnapshot<AppUser> snapshot) {
  //                               if (snapshot.connectionState ==
  //                                   ConnectionState.waiting) {
  //                                 return Container();
  //                               } else if (snapshot.hasError) {
  //                                 return Text('Error: ${snapshot.error}');
  //                               } else {
  //                                 comment.author = snapshot.data;

  //                                 return Padding(
  //                                   padding: const EdgeInsets.symmetric(
  //                                     vertical: 6.0,
  //                                     horizontal: 5.0,
  //                                   ),
  //                                   child: Container(
  //                                     decoration: BoxDecoration(
  //                                       borderRadius: BorderRadius.circular(8),
  //                                       color: Colors.white,
  //                                     ),
  //                                     child: Hero(
  //                                       tag: 'CommentsForum${comment.id}',
  //                                       child: Column(
  //                                         children: [
  //                                           ForumHeader(
  //                                             profilePhoto: profilePhoto,
  //                                             comment: comment,
  //                                           ),
  //                                           const SizedBox(height: 5),
  //                                           BodyData(
  //                                             forumController: forumController,
  //                                             comment: comment,
  //                                           ),
  //                                           Container(
  //                                             width: double.infinity,
  //                                             height: 1.5,
  //                                             color: Colors.grey[200],
  //                                           ),
  //                                           IconsActions(
  //                                             comment: comment,
  //                                             forumController: forumController,
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 );
  //                               }
  //                             },
  //                           );
  //                         },
  //                       );
  //                     } else {
  //                       return const Text(
  //                           'No hay comentarios disponibles en el foro');
  //                     }
  //                   }
  //                 },
  //               );
  //             },
  //           ),
  //           floatingActionButton: FloatingActionButton(
  //             child: const Icon(
  //               Icons.add_comment,
  //             ),
  //             onPressed: () {
  //               // _showCreateGroupScreen();
  //             },
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }
}
