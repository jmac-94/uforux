import 'package:faker/faker.dart';
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 10,
        ),
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
        const Spacer(),
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
        const SizedBox(
          width: 15,
        ),
      ],
    );
  }

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
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/clouds.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: Image.network(
                                'https://lastfm.freetls.fastly.net/i/u/ar0/9e3232f437c90e5ece62dd0b5df2950b.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Ayuda!! nesecito ayuda en ADA ayudaa.',
                                style: TextStyle(
                                  fontSize: 24,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Row(
                              children: [
                                const Spacer(),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.local_fire_department_outlined,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.more_horiz),
                                ),
                              ],
                            ),
                            const Divider(),
                            Flexible(
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  final Comment comment = widget
                                      .comment.comments!.values
                                      .toList()[index];
                                  return ListTile(
                                    title: Text(comment.text),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const Divider(),
                                itemCount: commentNum - 1,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
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

  int getCommentsLen() {
    final Map<String, Comment>? comments = widget.comment.comments;
    if (comments != null) {
      return comments.length;
    } else {
      return 0;
    }
  }
}
