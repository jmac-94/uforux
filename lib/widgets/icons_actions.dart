import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uforuxpi3/controllers/home_controller.dart';
import 'package:uforuxpi3/models/comment.dart';
import 'package:uuid/uuid.dart';

class IconsActions extends StatefulWidget {
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
  State<IconsActions> createState() => _IconsActionsState();
}

class _IconsActionsState extends State<IconsActions> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  isLiked = !isLiked;
                });
              },
              icon: Icon(
                isLiked
                    ? Icons.local_fire_department
                    : Icons.local_fire_department_outlined,
                size: 25,
              ),
              constraints: const BoxConstraints.tightFor(
                width: 35,
              ),
            ),
            Text('${widget.comment.ups}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(width: 15),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                const String text = 'Este es mi primer subcomentario.';

                // crear el subcomment
                final String userId = widget.homeController.userId;
                Comment subcomment = Comment.fromJson({
                  'id': widget.uuid.v1(),
                  'userId': userId,
                  'text': text,
                  'ups': 0,
                  'createdAt': Timestamp.now(),
                  'attachments': [],
                });

                await widget.homeController
                    .submitSubcomment(widget.comment, subcomment);
              },
              icon: const Icon(
                Icons.comment,
                size: 25,
              ),
              constraints: const BoxConstraints.tightFor(
                width: 37,
              ),
            ),
            Text(
              getCommentsLen(),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(width: 15),
        Row(
          children: [
            IconButton(
              onPressed: () {
                commentsInfo(context);
              },
              icon: const Icon(
                Icons.more_horiz,
                size: 25,
              ),
              constraints: const BoxConstraints.tightFor(
                width: 37,
              ),
            ),
          ],
        ),
      ],
    );
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

  String getCommentsLen() {
    final Map<String, Comment>? comments = widget.comment.comments;
    if (comments != null) {
      return comments.length.toString();
    } else {
      return '0';
    }
  }
}
