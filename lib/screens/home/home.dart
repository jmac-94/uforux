import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:uforuxpi3/controllers/home_controller.dart';
import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/models/comment_data.dart';
import 'package:uforuxpi3/structures/pair.dart';
import 'package:uforuxpi3/widgets/homeW/body_data.dart';
import 'package:uforuxpi3/widgets/homeW/forum_header.dart';
import 'package:uforuxpi3/widgets/homeW/icons_actions.dart';

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
  late HomeController _homeController;
  Map<String, List<Pair<String, File>>>? files = {};

  CommentData getCommentData(int index) {
    var commentsList = _homeController.comments.values.toList();
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
        _homeController.hasMoreData) {
      _homeController.fetchComments();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _homeController = HomeController(widget.user.id);
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
        // Positioned.fill(
        //   child: Image.asset(
        //     'assets/images/clouds.jpg',
        //     fit: BoxFit.cover,
        //   ),
        Container(
          color: Colors.grey[100],
        ),

        Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AppBar(
              backgroundColor: Colors.blueGrey[600],
              shadowColor: Colors.transparent,
              title: const Text(
                'Foro general',
              ),
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
            ),
          ),
          backgroundColor: Colors.grey[100],
          body: RefreshIndicator(
            onRefresh: () async {
              await _homeController.fetchComments(isRefresh: true);
              setState(() {});
            },
            child: FutureBuilder<void>(
              future: _homeController.initialFetchDone
                  ? null
                  : _homeController.fetchComments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !_homeController.initialFetchDone) {
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
                    itemCount: _homeController.hasMoreData
                        ? _homeController.comments.length + 1
                        : _homeController.comments.length,
                    itemBuilder: (context, index) {
                      if (index == _homeController.comments.length) {
                        if (_homeController.hasMoreData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return Container(); // No more data to load
                        }
                      }

                      var commentData = getCommentData(index);
                      var comment = commentData.comment;

                      return FutureBuilder<AppUser>(
                        future: _homeController.fetchAppUser(comment.userId),
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
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                child: Hero(
                                  tag: 'CommentsForum',
                                  child: Column(
                                    children: [
                                      ForumHeader(
                                        profilePhoto: commentData.profilePhoto,
                                        name: name,
                                        realTime: commentData.realTime,
                                      ),
                                      const SizedBox(height: 5),
                                      BodyData(
                                        image: commentData.image,
                                        hasImage: commentData.hasImage,
                                        text: comment.text,
                                        comment: comment,
                                        homeController: _homeController,
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 1.5,
                                        color: Colors.grey[200],
                                      ),
                                      IconsActions(
                                        hasImage: commentData.hasImage,
                                        comment: comment,
                                        homeController: _homeController,
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
                    _homeController.submitComment(text, filesMap);
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
