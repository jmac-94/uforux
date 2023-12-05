import 'dart:io';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:uforuxpi3/app/controllers/forum_controller.dart';
import 'package:uforuxpi3/app/models/app_user.dart';
import 'package:uforuxpi3/app/models/comment.dart';
import 'package:uforuxpi3/app/models/forum.dart';
import 'package:uforuxpi3/app/widgets/home/body_data.dart';
import 'package:uforuxpi3/app/widgets/home/forum_header.dart';
import 'package:uforuxpi3/app/widgets/home/icons_actions.dart';
import 'package:uforuxpi3/core/structures/pair.dart';

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
  final ScrollController _scrollController = ScrollController();
  TextEditingController commentController = TextEditingController();
  late ForumController forumController;
  Map<String, List<Pair<String, File>>>? files = {};

  String getUserProfilePhoto(Comment comment) {
    final profilePhoto =
        'https://random.imagecdn.app/500/${faker.randomGenerator.integer(1000)}';

    return profilePhoto;
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        forumController.hasMoreData) {
      forumController.loadComments();
    }
  }

  @override
  void initState() {
    super.initState();
    Forum forum = Forum(name: 'general', comments: {});
    forumController = ForumController(
      forum: forum,
      loggedUserId: widget.user.id,
    );
    forumController.init();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
                      Colors.blue.shade900, // Color de inicio del degradado
                      Colors.blue.shade700, // Color de fin del degradado
                    ],
                  ),
                ),
              ),
              shadowColor: Colors.transparent,
            ),
          ),
          backgroundColor: Colors.grey[100],
          body: RefreshIndicator(
            onRefresh: () async {
              await forumController.loadComments(isRefresh: true);
              setState(() {});
            },
            child: FutureBuilder<void>(
              future: forumController.initialFetchDone
                  ? null
                  : forumController.loadComments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !forumController.initialFetchDone) {
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
                    itemCount: forumController.hasMoreData
                        ? forumController.forum.comments.length + 1
                        : forumController.forum.comments.length,
                    itemBuilder: (context, index) {
                      if (index == forumController.forum.comments.length) {
                        if (forumController.hasMoreData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return Container();
                        }
                      }

                      // Get current comment from index
                      final List<Comment> commentsList =
                          forumController.forum.comments.values.toList();
                      final Comment comment = commentsList[index];

                      // Get current comment properties
                      final String profilePhoto = getUserProfilePhoto(comment);

                      return FutureBuilder<AppUser>(
                        future: forumController.fetchAppUser(comment.userId),
                        builder: (BuildContext context,
                            AsyncSnapshot<AppUser> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            // Get current comment author username
                            comment.author = snapshot.data;

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
                                      ForumHeader(
                                        profilePhoto: profilePhoto,
                                        comment: comment,
                                      ),
                                      const SizedBox(height: 5),
                                      BodyData(
                                        forumController: forumController,
                                        comment: comment,
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 1.5,
                                        color: Colors.grey[200],
                                      ),
                                      IconsActions(
                                        comment: comment,
                                        forumController: forumController,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                    separatorBuilder: (context, index) => Container(),
                  );
                }
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(
              Icons.add_comment,
            ),
            onPressed: () {
              _showDialog();
            },
          ),
        ),
      ],
    );
  }

  void _showDialog() {
    TextEditingController commentController = TextEditingController();
    Map<String, List<Pair<String, File>>> filesMap = {};
    List<String> uploadedFileNames = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nuevo foro'),
              icon: const Icon(Icons.add_home_rounded),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu comentario aquí',
                      ),
                    ),
                    ElevatedButton(
                      child: const Text('Añadir archivos'),
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(allowMultiple: true);
                        if (result != null) {
                          for (var pickedFile in result.files) {
                            String path = pickedFile.path!;
                            File file = File(path);
                            String extension = pickedFile.extension!;
                            String name = pickedFile.name;
                            uploadedFileNames.add(name);
                            String type;
                            if (extension == 'pdf') {
                              type = 'documents';
                            } else if ([
                              'jpg',
                              'jpeg',
                              'png',
                              'gif',
                              'bmp',
                              'webp'
                            ].contains(extension)) {
                              type = 'images';
                            } else {
                              continue;
                            }
                            if (filesMap.containsKey(type)) {
                              filesMap[type]!.add(Pair(name, file));
                            } else {
                              filesMap[type] = [Pair(name, file)];
                            }
                          }
                          setState(() {});
                        } else {}
                      },
                    ),
                    if (uploadedFileNames.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: uploadedFileNames.map(
                            (fileName) {
                              return Text(
                                fileName,
                                style: const TextStyle(fontSize: 16),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Enviar'),
                  onPressed: () {
                    String text = commentController.text;
                    Navigator.of(context).pop();
                    forumController.submitComment(text, filesMap);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
