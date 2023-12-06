import 'dart:io';
import 'package:awesome_icons/awesome_icons.dart';
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
  late ForumController forumController;

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

  void _showCreateGroupScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CreateGroupScreen(
        forumController: forumController,
      ),
    ));
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
              _showCreateGroupScreen();
            },
          ),
        ),
      ],
    );
  }
}

class CreateGroupScreen extends StatefulWidget {
  final ForumController forumController;

  const CreateGroupScreen({
    super.key,
    required this.forumController,
  });

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Map<String, List<Pair<String, File>>> filesMap = {};
  List<String> uploadedFileNames = [];

  List<String> allLabels = [
    'Flutter',
    'Dart',
    'Firebase',
    'UI/UX',
    'Backend',
    'Frontend'
  ];
  List<String> selectedLabels = [];

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
                      Colors.blueAccent.shade100,
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
                  return allLabels.where((String label) {
                    return label
                        .toLowerCase()
                        .startsWith(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selectedEtiqueta) {
                  setState(() {
                    if (!selectedLabels.contains(selectedEtiqueta)) {
                      selectedLabels.add(selectedEtiqueta);
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
                    (etiqueta) => Chip(
                      label: Text(etiqueta),
                      onDeleted: () {
                        setState(
                          () {
                            selectedLabels.remove(etiqueta);
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
        onPressed: () {
          String title = titleController.text;
          String description = descriptionController.text;
          Navigator.of(context).pop();
          widget.forumController.submitComment(title, description, filesMap);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
