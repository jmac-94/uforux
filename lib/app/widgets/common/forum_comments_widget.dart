import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';

import 'package:forux/app/controllers/forum_controller.dart';
import 'package:forux/app/models/app_user.dart';
import 'package:forux/app/models/comment.dart';
import 'package:forux/app/models/forum.dart';
import 'package:forux/app/widgets/home/body_data.dart';
import 'package:forux/app/widgets/home/forum_header.dart';
import 'package:forux/app/widgets/common/icons_actions.dart';
import 'package:forux/core/structures/pair.dart';
import 'package:forux/core/utils/const.dart';
import 'package:forux/core/utils/extensions.dart';

class ForumCommentsWidget extends StatefulWidget {
  final String loggedUserId;
  final String title;

  const ForumCommentsWidget({
    super.key,
    required this.loggedUserId,
    required this.title,
  });

  @override
  State<ForumCommentsWidget> createState() => _ForumCommentsWidgetState();
}

class _ForumCommentsWidgetState extends State<ForumCommentsWidget> {
  final ScrollController _scrollController = ScrollController();
  late ForumController forumController;

  @override
  void initState() {
    super.initState();

    Forum forum =
        Forum(name: widget.title.removeAccentsAndToLowercase(), comments: {});

    forumController = ForumController(
      forum: forum,
      loggedUserId: widget.loggedUserId,
    );
    forumController.init();

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        forumController.hasMoreData) {
      forumController.loadComments();
    }
  }

  void _showCreateGroupScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateGroupScreen(
          forumController: forumController,
          onCommentSubmitted: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  // void commentsInfo(BuildContext context, Comment comment) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (BuildContext context) => CommentsInfoPage(
  //         comment: comment,
  //         forumController: forumController,
  //         onLikeChanged: (bool newLikeStatus) {
  //           setState(() {
  //             isLiked = newLikeStatus;
  //           });
  //         },
  //         isLiked: isLiked,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                  return FutureBuilder<AppUser>(
                    future: forumController.fetchAppUser(comment.userId),
                    builder: (BuildContext context,
                        AsyncSnapshot<AppUser> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: 5,
                                  offset: const Offset(
                                      0, 1), // changes position of shadow
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                // setState(() {});
                                // commentsInfo(context, comment);
                              },
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
                                  IconsActions(
                                    comment: comment,
                                    forumController: forumController,
                                  ),
                                  const SizedBox(height: 5),
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
          _showCreateGroupScreen();
        },
      ),
    );
  }
}

class CreateGroupScreen extends StatefulWidget {
  final ForumController forumController;
  final VoidCallback onCommentSubmitted;

  const CreateGroupScreen({
    super.key,
    required this.forumController,
    required this.onCommentSubmitted,
  });

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Map<String, List<Pair<String, File>>> filesMap = {};
  List<String> uploadedFileNames = [];
  List<String> selectedLabels = [];

  @override
  void initState() {
    super.initState();

    final String? forumName = widget.forumController.forum.name;
    if (forumName != null) {
      selectedLabels.add(forumName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.playlist_add,
                  color: Colors.blue[800],
                ),
                const SizedBox(width: 10),
                //const Icon(Icons.add_location),
              ],
            ),
            const Text(
              'Crear un nuevo grupo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Escribe un comentario para crear un nuevo grupo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 50),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  'Titulo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.08,
              ),
              child: TextField(
                textAlign: TextAlign.left,
                controller: titleController,
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu idea aca',
                  border: InputBorder.none,
                  hintMaxLines: 3,
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.08,
              ),
              child: TextField(
                textAlign: TextAlign.left,
                controller: descriptionController,
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  hintText: 'Escribe un poco mas detallado tu pregunta',
                  border: InputBorder.none,
                  hintMaxLines: 3,
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  'Archivo adjuntos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 10,
                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.blue[400]!,
                    ), // Establece tu color aquí
                  ),
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
                        } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
                            .contains(extension)) {
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
                  child: const Text(
                    'Añadir archivos',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w300),
                  ),
                ),
              ),
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  'Etiquetas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return Constants.labels.where((String label) {
                    return label
                        .toLowerCase()
                        .startsWith(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selectedlabel) {
                  setState(() {
                    if (!selectedLabels.contains(selectedlabel)) {
                      selectedLabels.add(selectedlabel);
                    }
                  });
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    decoration: const InputDecoration(
                      hintText: 'Escribe para buscar etiquetas',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: selectedLabels
                  .map(
                    (label) => Chip(
                      label: Text(label),
                      onDeleted: () {
                        setState(
                          () {
                            selectedLabels.remove(label);
                          },
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String title = titleController.text;
          String description = descriptionController.text;
          Navigator.of(context).pop();

          await widget.forumController
              .submitComment(title, description, filesMap, selectedLabels);

          widget.onCommentSubmitted();
          setState(() {});
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
