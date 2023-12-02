import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:uforuxpi3/controllers/course_controller.dart';
import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/models/comment_data.dart';
import 'package:uforuxpi3/structures/pair.dart';
import 'package:uforuxpi3/util/dprint.dart';
import 'package:uforuxpi3/widgets/homeW/body_data.dart';
import 'package:uforuxpi3/widgets/homeW/forum_header.dart';
import 'package:uforuxpi3/widgets/homeW/icons_actions.dart';

void main() {
  runApp(MaterialApp(
    home: DetailScreen(
      title: 'View',
    ),
  ));
}

class DetailScreen extends StatefulWidget {
  final String title;

  const DetailScreen({super.key, required this.title});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ScrollController _scrollController = ScrollController();
  late CourseController courseController;

  String removeAccentsAndToLowercase(String text) {
    const accents = 'áéíóúÁÉÍÓÚ';
    const withoutAccents = 'aeiouAEIOU';

    for (int i = 0; i < accents.length; i++) {
      text = text.replaceAll(accents[i], withoutAccents[i]);
    }

    return text.toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    courseController = CourseController(
        userId: 'bnVVq7WpH1hMJtkCO4Igej1B4Lb2',
        courseName: removeAccentsAndToLowercase(widget.title));
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  CommentData getCommentData(int index) {
    var commentsList = courseController.comments.values.toList();
    var comment = commentsList[index];
    final realTime = timeago.format(comment.createdAt.toDate());
    const profilePhoto =
        'https://pbs.twimg.com/profile_images/1508500949400129537/4gQ4z4Na_400x400.jpg';
    String? image;
    bool hasImage = false;

    if (comment.attachments['images'] != null &&
        comment.attachments['images']!.isNotEmpty) {
      image = comment.attachments['images']?[0];
      hasImage = true;
    }

    return CommentData(
      comment: comment,
      realTime: realTime,
      profilePhoto: profilePhoto,
      image: image ?? '',
      hasImage: hasImage,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        courseController.hasMoreData) {
      courseController.fetchComments();
    }
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
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz_outlined, color: Colors.black),
              onPressed: () {},
            ),
          ],
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Joined'),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.notifications_none,
                        color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const TabBar(
              indicatorColor: Colors.red,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'All Discussions'),
                Tab(text: 'Wikipedia'),
                Tab(text: 'Teachers'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      await courseController.fetchComments(isRefresh: true);
                      setState(() {});
                    },
                    child: FutureBuilder<void>(
                      future: courseController.initialFetchDone
                          ? null
                          : courseController.fetchComments(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !courseController.initialFetchDone) {
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
                            itemCount: courseController.hasMoreData
                                ? courseController.comments.length + 1
                                : courseController.comments.length,
                            itemBuilder: (context, index) {
                              if (index == courseController.comments.length) {
                                if (courseController.hasMoreData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else {
                                  return Container();
                                }
                              }

                              var commentData = getCommentData(index);
                              var comment = commentData.comment;

                              return FutureBuilder<AppUser>(
                                future: courseController
                                    .fetchAppUser(comment.userId),
                                builder: (BuildContext context,
                                    AsyncSnapshot<AppUser> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    final commentAuthor = snapshot.data;
                                    final String name = commentAuthor != null
                                        ? (commentAuthor.username ?? '')
                                        : '';

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                        horizontal: 5.0,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: Hero(
                                          tag: 'CommentsForum',
                                          child: Column(
                                            children: [
                                              ForumHeader(
                                                profilePhoto:
                                                    commentData.profilePhoto,
                                                name: name,
                                                realTime: commentData.realTime,
                                              ),
                                              const SizedBox(height: 5),
                                              BodyData(
                                                image: commentData.image,
                                                hasImage: commentData.hasImage,
                                                text: comment.text,
                                                comment: comment,
                                                homeController:
                                                    courseController,
                                              ),
                                              Container(
                                                width: double.infinity,
                                                height: 1.5,
                                                color: Colors.grey[200],
                                              ),
                                              IconsActions(
                                                hasImage: commentData.hasImage,
                                                comment: comment,
                                                homeController:
                                                    courseController,
                                                date: commentData.realTime,
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
                  const Center(child: Text('Wikipedia Content')),
                  const Center(child: Text('Members Content')),
                ],
              ),
            ),
          ],
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
                    courseController.submitComment(text, filesMap);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildCommentsListView() {
    return ListView.separated(
      controller: _scrollController,
      itemCount: courseController.hasMoreData
          ? courseController.comments.length + 1
          : courseController.comments.length,
      itemBuilder: (context, index) {
        if (index == courseController.comments.length) {
          if (courseController.hasMoreData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Container(); // No more data to load
          }
        }

        // Aquí, puedes agregar tu lógica para construir cada elemento de la lista.
        // Por ejemplo, usando `courseController.comments[index]`...
      },
      separatorBuilder: (context, index) => Container(),
    );
  }
}
