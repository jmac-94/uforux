import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:uforuxpi3/app/controllers/forum_controller.dart';
import 'package:uforuxpi3/app/models/comment.dart';
import 'package:uforuxpi3/app/models/subcomment.dart';
import 'package:uforuxpi3/core/utils/dprint.dart';
import 'package:uforuxpi3/core/utils/extensions.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;

class IconsActions extends StatefulWidget {
  final Comment comment;
  final uuid = const Uuid();
  final ForumController forumController;

  const IconsActions({
    super.key,
    required this.comment,
    required this.forumController,
  });

  @override
  State<IconsActions> createState() => _IconsActionsState();
}

class _IconsActionsState extends State<IconsActions> {
  bool isLiked = false;
  late int subcommentNum;

  @override
  void initState() {
    super.initState();
    subcommentNum = getSubcommentsLen();
    fetchUserLikeStatus();
  }

  void fetchUserLikeStatus() async {
    bool userLikeStatus =
        await widget.forumController.hasUserLikedComment(widget.comment.id);

    if (mounted) {
      setState(() {
        isLiked = userLikeStatus;
      });
    }
  }

  int getSubcommentsLen() {
    final Map<String, Subcomment>? subcomments = widget.comment.subcomments;
    if (subcomments != null) {
      return subcomments.length;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 10.0,
          ),
          child: Row(
            children: widget.comment.labels.skip(1).map((label) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 5,
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Center(
                      child: Text(
                        label.capitalize(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                setState(() {
                  isLiked = !isLiked;
                });

                await widget.forumController
                    .updateCommentLikes(widget.comment.id, isLiked);
              },
              icon: Icon(
                isLiked
                    ? Icons.local_fire_department
                    : Icons.local_fire_department_outlined,
                size: 24,
              ),
              constraints: const BoxConstraints.tightFor(
                width: 34,
              ),
            ),
            Text('${widget.comment.ups}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(width: 5),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                setState(() {});
                commentsInfo(context);
                //! Automaticamente se abre para insetar un nuevo comentario
                showModalBottomSheet(
                  context: context,
                  builder: (context) => CommentSection(
                    forumController: widget.forumController,
                    comment: widget.comment,
                    onCommentSubmitted: () {
                      setState(() {});
                    },
                  ),
                );
              },
              icon: const Icon(
                Icons.comment,
                size: 24,
              ),
              constraints: const BoxConstraints.tightFor(
                width: 36,
              ),
            ),
            Text(
              subcommentNum.toString(),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  void commentsInfo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => CommentsInfoPage(
          comment: widget.comment,
          forumController: widget.forumController,
        ),
      ),
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
              future: widget.forumController.fetchImage(attachment),
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

class CommentsInfoPage extends StatefulWidget {
  final Comment comment;
  final ForumController forumController;

  const CommentsInfoPage({
    super.key,
    required this.comment,
    required this.forumController,
  });

  @override
  State<CommentsInfoPage> createState() => _CommentsInfoPageState();
}

class _CommentsInfoPageState extends State<CommentsInfoPage> {
  late int subcommentNum;

  @override
  void initState() {
    super.initState();
    subcommentNum = widget.comment.subcomments?.length ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    // Aquí va el contenido de tu página, similar a lo que tenías en el método commentsInfo
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Material(
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28.0),
                        child: Image.network(
                          'https://random.imagecdn.app/500/${faker.randomGenerator.integer(1000)}',
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          widget.comment.author?.username
                                  .toString()
                                  .capitalize() ??
                              '',
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Text(
                        'desde ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      Text(
                        ' ${widget.comment.labels[0]}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 8.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              widget.comment.title,
                              style: const TextStyle(
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        widget.comment.description,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        maxLines: 5,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          timeago.format(widget.comment.createdAt.toDate()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.local_fire_department_outlined,
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
                                forumController: widget.forumController,
                                comment: widget.comment,
                                onCommentSubmitted: () {
                                  setState(() {});
                                },
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.comment,
                          ),
                        ),
                        Text(
                          subcommentNum.toString(),
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
                        final Subcomment subcomment =
                            widget.comment.subcomments!.values.toList()[index];
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: ClipOval(
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    color: Colors.grey[400],
                                    child: Image.network(
                                      'https://random.imagecdn.app/500/${faker.randomGenerator.integer(1000)}',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            faker.person.name().toString(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Container(
                                            padding: const EdgeInsets.all(4.0),
                                            decoration: BoxDecoration(
                                              color: Colors.red[100],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'STD',
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(
                                            Icons.access_time,
                                            size: 11,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            timeago.format(widget
                                                .comment.createdAt
                                                .toDate()),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      subcomment.text,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        height: 20,
                        color: Colors.transparent,
                      ),
                      itemCount: subcommentNum,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CommentSection extends StatefulWidget {
  final ForumController forumController;
  final Comment comment;
  final VoidCallback onCommentSubmitted;

  const CommentSection({
    super.key,
    required this.forumController,
    required this.comment,
    required this.onCommentSubmitted,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final uuid = const Uuid();
  final TextEditingController _commentController = TextEditingController();

  void _sendComment() async {
    try {
      String subcommentText = _commentController.text;

      final String userId = widget.forumController.loggedUserId;

      Subcomment subcomment = Subcomment.fromJson({
        'id': uuid.v1(),
        'userId': userId,
        'text': subcommentText,
        'ups': 0,
        'createdAt': Timestamp.now(),
        'attachments': {},
        'labels': [],
      });

      await widget.forumController.submitSubcomment(widget.comment, subcomment);

      _commentController.clear();

      widget.onCommentSubmitted();

      // ignore: use_build_context_synchronously
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
