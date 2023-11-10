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
  State<Home> createState() => _HomeState();
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
                          faker.lorem.sentence().characters.take(30).toString();
                      final isImage = faker.randomGenerator.boolean();
                      // ----------------------------------------------------------------------

                      return Hero(
                        tag: 'CommentsForum',
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              // put a gif image
                              // image: const DecorationImage(
                              //   image: AssetImage('assets/images/giphy.gif'),
                              //   fit: BoxFit.cover,
                              // ),
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
                                HeaderF(
                                  imageUrl: imageUrl,
                                  name: name,
                                  realTime: realTime,
                                ),
                                const SizedBox(height: 5),
                                Column(
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
                                IconsActions(
                                  isImage: isImage,
                                  comment: comment,
                                  homeController: _homeController,
                                ),
                                const SizedBox(height: 10),
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
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        //color: Colors.blue[100],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        child: Row(children: [
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
            padding: const EdgeInsets.all(5.0),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ),
          const Text(
            'del curso de ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w200,
            ),
          ),
          const Text(
            'MATH',
            style: TextStyle(
              fontSize: 11,
              color: Colors.blueAccent,
            ),
          ),
          const Spacer(),
          Text(
            realTime,
            style: const TextStyle(
              fontSize: 11,
            ),
          ),
        ]),
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
      alignment: Alignment.center,
      child: Text(
        randomText,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
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
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          : Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    '${comment.text}   norem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod, nisl eget aliquam ultricies, nisl nisl aliquet nisl, nec aliquam nisl nisl nec nisl. Donec euismod, nisl eget aliquam ultricies, nisl nisl aliquet nisl, nec aliquam nisl nisl nec nisl.',
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.local_fire_department,
                size: 25,
              ),
              constraints: const BoxConstraints.tightFor(
                width: 35,
              ),
            ),
            const Text('594', style: TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(width: 15),
        Row(
          children: [
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
                size: 25,
              ),
              constraints: const BoxConstraints.tightFor(
                width: 37,
              ),
            ),
            const Text(
              '32',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(width: 15),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.more_horiz,
                size: 25,
              ),
              constraints: const BoxConstraints.tightFor(
                width: 37,
              ),
            ),
            const Text(
              '2',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
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
          child: Container(
            width: MediaQuery.of(context).size.width * 1.3,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
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
