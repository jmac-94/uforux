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
  late int commentNum;

  @override
  void initState() {
    super.initState();
    commentNum = getCommentsLen();
  }

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
                setState(() {
                  commentNum++;
                });
                // const String text = 'Este es mi primer subcomentario.';

                // crear el subcomment
                final String userId = widget.homeController.userId;
                /*  Comment subcomment = Comment.fromJson({
                  'id': widget.uuid.v1(),
                  'userId': userId,
                  'text': text,
                  'ups': 0,
                  'createdAt': Timestamp.now(),
                  'attachments': [],
                });*/
                commentsInfo(context);
                // await widget.homeController
                //    .submitSubcomment(widget.comment, subcomment);
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
              commentNum.toString(),
              style: const TextStyle(fontSize: 12),
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
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
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
                              title: const Text('Comments'),
                              automaticallyImplyLeading: false,
                              actions: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                            body: ListView.separated(
                              itemBuilder: (context, index) {
                                final Comment comment = widget
                                    .comment.comments!.values
                                    .toList()[index];
                                return ListTile(
                                  title: Text(comment.text + index.toString()),
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemCount: commentNum - 1,
                            )),
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

  int getCommentsLen() {
    final Map<String, Comment>? comments = widget.comment.comments;
    if (comments != null) {
      return comments.length;
    } else {
      return 0;
    }
  }
}
