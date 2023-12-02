import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:uforuxpi3/controllers/home_controller.dart';
import 'package:uforuxpi3/controllers/course_controller.dart';
import 'package:uforuxpi3/models/comment.dart';
import 'package:uforuxpi3/util/dprint.dart';
import 'package:uuid/uuid.dart';

class IconsActions extends StatefulWidget {
  final bool hasImage;
  final Comment comment;
  final uuid = const Uuid();
  final String date;

  ///////////////////////////// TEMPORAL
  // Agregar clase padre para homeController y courseController para que
  // ambas puedan estar aqui
  final dynamic homeController;
  ///////////////////////////////////////

  const IconsActions({
    super.key,
    required this.hasImage,
    required this.comment,
    required this.homeController,
    required this.date,
  });

  @override
  State<IconsActions> createState() => _IconsActionsState();
}

class _IconsActionsState extends State<IconsActions> {
  bool isLiked = false;
  late int commentNum;

  @override
  void initState() {
    super.initState();
    commentNum = getCommentsLen();
    fetchUserLikeStatus();
  }

  void fetchUserLikeStatus() async {
    bool userLikeStatus =
        await widget.homeController.fetchUserLikeStatus(widget.comment.id);

    if (mounted) {
      setState(() {
        isLiked = userLikeStatus;
      });
    }
  }

  int getCommentsLen() {
    final Map<String, Comment>? comments = widget.comment.comments;
    if (comments != null) {
      return comments.length;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 5,
        ),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                setState(() {
                  isLiked = !isLiked;
                  widget.comment.ups =
                      isLiked ? widget.comment.ups + 1 : widget.comment.ups - 1;
                });
                await widget.homeController
                    .updateCommentLikes(widget.comment.id, isLiked);
              },
              icon: Icon(
                isLiked
                    ? Icons.local_fire_department
                    : Icons.local_fire_department_outlined,
                size: 20,
              ),
              constraints: const BoxConstraints.tightFor(
                width: 30,
              ),
            ),
            Text('${widget.comment.ups}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Row(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      setState(() {});
                      commentsInfo(context);
                    },
                    icon: const Icon(
                      Icons.comment,
                      size: 20,
                    ),
                    constraints: const BoxConstraints.tightFor(
                      width: 32,
                    ),
                  ),
                  Text(
                    commentNum.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                widget.date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                width: 10,
              )
            ],
          ),
        ),
      ],
    );
  }

  // SubComentarios
  void commentsInfo(BuildContext context) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (BuildContext context) {
        return SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Hero(
                tag: 'CommentsForum',
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  child: Material(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: Image.network(
                                'https://images.unsplash.com/photo-1700771266232-7a31af68eb31?q=80&w=3432&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      widget.comment.text,
                                      style: const TextStyle(
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    widget.date,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.0),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  'lorem ipsum dolor sit amet, consectetur elit, nisl eget aliquam ultricies, nisl nisl aliquam nisl, nec aliquam nisl ',
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  maxLines: 5,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      isLiked
                                          ? Icons.local_fire_department
                                          : Icons
                                              .local_fire_department_outlined,
                                      size: 20,
                                    ),
                                  ),
                                  Text(
                                    '${widget.comment.ups}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) => CommentSection(
                                          homeController: widget.homeController,
                                          comment: widget.comment,
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.comment,
                                    ),
                                  ),
                                  Text(
                                    commentNum.toString(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            Flexible(
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  final Comment comment = widget
                                      .comment.comments!.values
                                      .toList()[index];
                                  return Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      ClipOval(
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          color: Colors.grey[400],
                                          child: Image.network(
                                            'https://random.imagecdn.app/500/${faker.randomGenerator.integer(1000)}',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(comment.text),
                                      const Spacer(),
                                      Text(
                                        widget.date,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const Divider(),
                                itemCount: commentNum,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget createCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 16 / 9,
        viewportFraction: 1.0,
        enableInfiniteScroll: false,
      ),
      items: widget.comment.attachments['images']?.map((attachment) {
            return FutureBuilder<Image>(
              future: widget.homeController.getImage(attachment),
              builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Column(
                        children: [
                          snapshot.data!,
                          const SizedBox(height: 10),
                          Text(
                            attachment,
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          }).toList() ??
          [],
    );
  }
}

class CommentSection extends StatefulWidget {
  // TAMBIEN CAMBIAR ESTOOOOOOOOOOOOO PARA CONTROLLER HOME Y COURSE
  final dynamic homeController;
  final Comment comment;

  const CommentSection(
      {super.key, required this.homeController, required this.comment});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final uuid = const Uuid();
  final TextEditingController _commentController = TextEditingController();

  void _sendComment() async {
    try {
      String subcommentText = _commentController.text;

      final String userId = widget.homeController.userId;

      Comment subcomment = Comment.fromJson({
        'id': uuid.v1(),
        'userId': userId,
        'text': subcommentText,
        'ups': 0,
        'createdAt': Timestamp.now(),
        'attachments': {},
      });

      await widget.homeController.submitSubcomment(widget.comment, subcomment);

      _commentController.clear();
      Navigator.pop(context);
    } catch (e) {
      dPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Escribe un comentario...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendComment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
