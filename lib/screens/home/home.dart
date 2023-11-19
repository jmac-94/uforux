import 'dart:io';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:uforuxpi3/controllers/home_controller.dart';
import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/models/comment.dart';
import 'package:uforuxpi3/widgets/body_data.dart';
import 'package:uforuxpi3/widgets/forum_header.dart';
import 'package:uforuxpi3/widgets/icons_actions.dart';

class CommentData {
  final Comment comment;
  final String realTime;
  final String profilePhoto;
  final String image;
  final bool isImage;

  CommentData({
    required this.comment,
    required this.realTime,
    required this.profilePhoto,
    required this.image,
    required this.isImage,
  });
}

class Home extends StatefulWidget {
  final AppUser user;

  const Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ScrollController _scrollController = ScrollController();
  late HomeController _homeController;

  TextEditingController commentController = TextEditingController();
  Map<String, List<Pair<String, File>>>? files = {};

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_scrollListener);

    _homeController = HomeController(widget.user.id);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _homeController.hasMoreData) {
      _homeController.fetchComments();
    }
  }

  CommentData getCommentData(int index) {
    var commentsList = _homeController.comments.values.toList();
    var comment = commentsList[index];

    final realTime = timeago.format(comment.createdAt.toDate());

    final randomNumber = faker.randomGenerator.integer(1000);

    final profilePhoto = 'https://picsum.photos/200/300?random=$randomNumber';

    String? image;
    bool hasImage = false;
    if (comment.attachments['images'] != null &&
        comment.attachments['images']!.isNotEmpty) {
      image = comment.attachments['images']?.first;
      hasImage = true;
    }

    return CommentData(
      comment: comment,
      realTime: realTime,
      profilePhoto: profilePhoto,
      image: image ?? '',
      isImage: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/clouds.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: AppBar(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              title: const Text('Foro general'),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.low_priority,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.search,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notification_add_outlined,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
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
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
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

                            return Hero(
                              tag: 'CommentsForum',
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: const Offset(
                                            0, 1), // changes position of shadow
                                      ),
                                    ],
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey[100]!,
                                        Colors.grey[100]!,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: 15.0,
                                            top: 5,
                                          ),
                                          child: Text(
                                            'Because you follow CS',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w100,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ForumHeader(
                                        profilePhoto: commentData.profilePhoto,
                                        name: name,
                                        realTime: commentData.realTime,
                                      ),
                                      const SizedBox(height: 5),
                                      BodyData(
                                        image: commentData.image,
                                        isImage: commentData.isImage,
                                        text: comment.text,
                                        comment: comment,
                                      ),
                                      IconsActions(
                                        isImage: commentData.isImage,
                                        comment: comment,
                                        homeController: _homeController,
                                      ),
                                      const SizedBox(
                                        height: 10,
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
    List<String> uploadedFileNames =
        []; // List to store names of uploaded files

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Use StatefulBuilder to update the dialog content
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nuevo Comentario'),
              content: SingleChildScrollView(
                // Use SingleChildScrollView to handle overflow
                child: Column(
                  mainAxisSize: MainAxisSize.min, // To avoid dialog expansion
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
                            uploadedFileNames
                                .add(name); // Add file name to the list

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
                              continue; // Skip files with unsupported extensions
                            }

                            if (filesMap.containsKey(type)) {
                              filesMap[type]!.add(Pair(name, file));
                            } else {
                              filesMap[type] = [Pair(name, file)];
                            }
                          }
                          setState(
                              () {}); // Update the UI to show uploaded file names
                        } else {
                          // User canceled the picker
                        }
                      },
                    ),
                    // Display uploaded file names
                    if (uploadedFileNames.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: uploadedFileNames.map((fileName) {
                            return Text(
                              fileName,
                              style: const TextStyle(fontSize: 16),
                            );
                          }).toList(),
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

  // void _showDialog() {
  //   TextEditingController commentController = TextEditingController();
  //   Map<String, List<Pair<String, File>>> filesMap = {};

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Nuevo Comentario'),
  //         content: Column(
  //           children: [
  //             TextField(
  //               controller: commentController,
  //               decoration: const InputDecoration(
  //                 hintText: 'Escribe tu comentario aquí',
  //               ),
  //             ),
  //             ElevatedButton(
  //               child: const Text('Añadir archivos'),
  //               onPressed: () async {
  //                 FilePickerResult? result =
  //                     await FilePicker.platform.pickFiles(allowMultiple: true);

  //                 if (result != null) {
  //                   for (var pickedFile in result.files) {
  //                     String path = pickedFile.path!;
  //                     File file = File(path);
  //                     String extension = pickedFile.extension!;
  //                     String name = pickedFile.name;

  //                     String type;
  //                     if (extension == 'pdf') {
  //                       type = 'documents';
  //                     } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
  //                         .contains(extension)) {
  //                       type = 'images';
  //                     } else {
  //                       continue; // Skip files with unsupported extensions
  //                     }

  //                     if (filesMap.containsKey(type)) {
  //                       filesMap[type]!.add(Pair(name, file));
  //                     } else {
  //                       filesMap[type] = [Pair(name, file)];
  //                     }
  //                   }
  //                 } else {
  //                   // User canceled the picker
  //                 }
  //               },
  //             ),
  //           ],
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancelar'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Enviar'),
  //             onPressed: () {
  //               String text = commentController.text;
  //               Navigator.of(context).pop();
  //               _homeController.submitComment(text, filesMap);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
