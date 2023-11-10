import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import 'package:uforuxpi3/controllers/home_controller.dart';
import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/models/comment.dart';
import 'package:uforuxpi3/util/dprint.dart';

class Home extends StatefulWidget {
  final AppUser user;

  const Home({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ScrollController _scrollController = ScrollController();
  late HomeController _homeController;

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
          appBar: AppBar(
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
          floatingActionButton: FloatingActionButton(
            child: const Icon(
              Icons.add_comment,
            ),
            onPressed: () {
              TextEditingController commentController = TextEditingController();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Nuevo Comentario'),
                    content: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu comentario aquí',
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
                          _homeController.submitComment(text);
                        },
                      ),
                    ],
                  );
                },
              );
            },
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
                          return Container(); // No hay más datos para cargar
                        }
                      }
                      // ---------- COMMENTARIES DATA------------------------------------------
                      var commentsList =
                          _homeController.comments.values.toList();
                      var comment = commentsList[index];
                      final realTime =
                          timeago.format(comment.createdAt.toDate());

                      final randomNumber = faker.randomGenerator.integer(1000);
                      final imageUrl =
                          'https://picsum.photos/200/300?random=$randomNumber';
                      final randomNumber2 = faker.randomGenerator.integer(1000);
                      final imageUrl2 =
                          'https://picsum.photos/200/300?random=$randomNumber2';
                      //! Reemplazar por el nombre del usuario que hizo el comentario FIREBASE
                      final name = faker.person.name();
                      final randomText =
                          faker.lorem.sentence().characters.take(40).toString();
                      final isImage = faker.randomGenerator.boolean();
                      // ----------------------------------------------------------------------

                      return Hero(
                        tag: 'CommentsForum',
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[100],
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
                            ),
                            child: Column(
                              children: [
                                HeaderF(
                                  imageUrl: imageUrl,
                                  name: name,
                                  realTime: realTime,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          ...bodyData(
                                            imageUrl2,
                                            randomText,
                                            isImage,
                                            comment.text,
                                            comment,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconsActions(
                                      isImage: isImage,
                                      comment: comment,
                                      homeController: _homeController,
                                    ),
                                    const SizedBox(width: 5),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Container();
                    },
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class HeaderF extends StatelessWidget {
  const HeaderF({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.realTime,
  });

  final String imageUrl;
  final String name;
  final String realTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28.0),
            child: Image.network(
              imageUrl,
              width: 25,
              height: 25,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ),
          const Text(
            'from  ',
            style: TextStyle(
              fontSize: 11,
            ),
          ),
          const Text(
            ' #MATH',
            style: TextStyle(
              fontSize: 11,
              color: Colors.redAccent,
            ),
          ),
          const Spacer(),
          Text(
            realTime,
            style: const TextStyle(
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

List<Widget> bodyData(
  final String imageUrl2,
  final String randomText,
  final bool isImage,
  final String text,
  final Comment comment,
) {
  return [
    Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          randomText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.circular(12),
      ),
      child: isImage
          ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 8.0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl2,
                    height: 250,
                    width: 270,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            )
          : Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 6.0,
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    '${comment.text}   norem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod, nisl eget aliquam ultricies, nisl nisl aliquet nisl, nec aliquam nisl nisl nec nisl. Donec euismod, nisl eget aliquam ultricies, nisl nisl aliquet nisl, nec aliquam nisl nisl nec nisl.',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
    ),
    isImage
        ? Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 20,
              ),
              child: Text(
                comment.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        : const SizedBox(),
    const SizedBox(
      height: 10,
    ),
  ];
}

class IconsActions extends StatelessWidget {
  final bool isImage;
  final Comment comment;
  final HomeController homeController;
  final uuid = const Uuid();

  const IconsActions({
    super.key,
    required this.isImage,
    required this.comment,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    return isImage
        ? Column(
            children: [
              const Icon(
                Icons.local_fire_department,
                size: 30,
              ),
              const Text('324', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 10),
              IconButton(
                onPressed: () async {
                  dPrint(comment.id);
                  // texto para subcomment
                  const String text = 'Este es mi primer subcomentario.';

                  // crear el subcomment
                  final String userId = homeController.userId;
                  Comment subcomment = Comment.fromJson({
                    'id': uuid.v1(),
                    'userId': userId,
                    'text': text,
                    'ups': 0,
                    'createdAt': Timestamp.now(),
                    'attachments': [],
                  });

                  await homeController.submitSubcomment(comment, subcomment);
                },
                icon: const Icon(
                  Icons.comment,
                  size: 30,
                ),
              ),
              const Text('32', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 10),
              IconButton(
                onPressed: () {
                  commentsInfo(context);
                },
                icon: const Icon(
                  Icons.more_horiz,
                  size: 30,
                ),
              ),
              const Text('2', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 10),
            ],
          )
        : Column(
            children: [
              const Icon(
                Icons.local_fire_department,
                size: 26,
              ),
              const Text(
                '324',
                style: TextStyle(fontSize: 10),
              ),
              IconButton(
                constraints: const BoxConstraints(
                  maxHeight: 34,
                ),
                iconSize: 26,
                onPressed: () async {
                  dPrint(comment.id);
                  // texto para subcomment
                  const String text = 'Este es mi primer subcomentario.';

                  // crear el subcomment
                  final String userId = homeController.userId;
                  Comment subcomment = Comment.fromJson({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'userId': userId,
                    'text': text,
                    'ups': 0,
                    'createdAt': Timestamp.now(),
                    'attachments': [],
                  });

                  // agregar el subcomment al comment
                  await homeController.submitSubcomment(comment, subcomment);
                },
                icon: const Icon(
                  Icons.comment,
                ),
              ),
              const Text(
                '32',
                style: TextStyle(fontSize: 10),
              ),
              const SizedBox(height: 4),
              IconButton(
                onPressed: () {
                  commentsInfo(context);
                },
                icon: const Icon(
                  Icons.more_horiz,
                  size: 30,
                ),
              ),
              const Text('2', style: TextStyle(fontSize: 10)),
              const SizedBox(height: 10),
            ],
          );
  }
}

void commentsInfo(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(0),
        child: SafeArea(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 1.3,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: 'CommentsForum',
                      child: Scaffold(
                        appBar: AppBar(
                          title: const Text('Hero Dialog'),
                          automaticallyImplyLeading: false,
                        ),
                        body: const Center(
                          child: Text(
                            'Hello, World!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
