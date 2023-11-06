import 'package:cached_network_image/cached_network_image.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uforuxpi3/controllers/home_controller.dart';
import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/models/comment.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foro general'),
        actions: [
          IconTheme(
            data: IconThemeData(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.low_priority,
              ),
              onPressed: () {},
            ),
          ),
          IconTheme(
            data: IconThemeData(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.search,
              ),
              onPressed: () {},
            ),
          ),
          IconTheme(
            data: IconThemeData(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notification_add_outlined,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add_comment,
          color: Colors.white,
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
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return Container(); // No hay más datos para cargar
                    }
                  }
                  // ---------- COMMENTARIES DATA------------------------------------------
                  var comment = _homeController.comments[index];
                  final realTime = timeago.format(comment.createdAt);

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

                  return GestureDetector(
                    onTap: () {
                      showHeroDialog(context);
                    },
                    child: Hero(
                      tag: 'uniqueTextTag',
                      child: Column(
                        children: [
                          PersonDataForum(
                            imageUrl: imageUrl,
                            name: name,
                            realTime: realTime,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    ...forumData(
                                      imageUrl2,
                                      randomText,
                                      isImage,
                                      comment.text,
                                      comment,
                                    ),
                                  ],
                                ),
                              ),
                              IconsActions(isImage: isImage),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.5),
                    height: 0.1,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class PersonDataForum extends StatelessWidget {
  const PersonDataForum({
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
        horizontal: 5,
        vertical: 5,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28.0),
            child: GestureDetector(
              onTap: () => showFullImage(context, imageUrl),
              child: Image.network(
                imageUrl,
                width: 25,
                height: 25,
                fit: BoxFit.cover,
              ),
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

class IconsActions extends StatelessWidget {
  final isImage;
  const IconsActions({
    super.key,
    required this.isImage,
  });

  @override
  Widget build(BuildContext context) {
    return isImage
        ? const Column(
            children: [
              Icon(
                Icons.local_fire_department,
                size: 30,
              ),
              Text('324', style: TextStyle(fontSize: 12)),
              SizedBox(height: 10),
              Icon(
                Icons.comment,
                size: 30,
              ),
              Text('32', style: TextStyle(fontSize: 12)),
              SizedBox(height: 10),
              Icon(
                Icons.more_horiz,
                size: 30,
              ),
              Text('2', style: TextStyle(fontSize: 12)),
              SizedBox(height: 10),
            ],
          )
        : const Column(
            children: [
              Icon(
                Icons.local_fire_department,
                size: 26,
              ),
              Text('324', style: TextStyle(fontSize: 10)),
              SizedBox(height: 8),
              Icon(
                Icons.comment,
                size: 26,
              ),
              Text('32', style: TextStyle(fontSize: 10)),
              SizedBox(height: 8),
              Icon(
                Icons.more_horiz,
                size: 26,
              ),
              Text('2', style: TextStyle(fontSize: 10)),
              SizedBox(height: 10),
            ],
          );
  }
}

// posibly deprecaded function
void showFullImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (context) {
      var edgeInsets = const EdgeInsets.all(10);
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: edgeInsets,
        child: GestureDetector(
          onTap: () => Navigator.pop(context), // Closes the dialog on tap
          child: PhotoViewGallery.builder(
            itemCount: 1,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
          ),
        ),
      );
    },
  );
}

void showHeroDialog(BuildContext context) {
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
                      tag: 'uniqueTextTag',
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

List<Widget> forumData(
  final String imageUrl2,
  final String randomText,
  final bool isImage,
  final String text,
  final Comment comment,
) {
  return [
    Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
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
                  horizontal: 15.0,
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
                  horizontal: 15.0,
                  vertical: 8.0,
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
