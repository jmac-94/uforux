import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uforuxpi3/controllers/home_controller.dart';
import 'package:uforuxpi3/models/comment.dart';
import 'package:uforuxpi3/util/dprint.dart';
import 'package:uuid/uuid.dart';

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
            const Text(
              '2',
              style: TextStyle(fontSize: 12),
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
}
