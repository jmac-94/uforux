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
      builder: (BuildContext context) {
        return Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'CommentsForum',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 1,
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/clouds.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Scaffold(
                            backgroundColor: Colors.transparent,
                            appBar: AppBar(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
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
                            body: Column(
                              children: [
                                SizedBox(
                                  height: 200,
                                  width: 400,
                                  child: Image.network(
                                    'https://picsum.photos/200/300?random=${faker.randomGenerator.integer(1000)}',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const Text(
                                  'Loren ipsum dolor sit amet, consectetur  elit.',
                                  style: TextStyle(
                                    fontSize: 30,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const Divider(),
                                Expanded(
                                  child: ListView.separated(
                                    itemBuilder: (context, index) {
                                      final Comment comment = widget
                                          .comment.comments!.values
                                          .toList()[index];
                                      return ListTile(
                                        title: Text(
                                            comment.text + index.toString()),
                                      );
                                    },
                                    separatorBuilder: (context, index) =>
                                        const Divider(),
                                    itemCount: commentNum - 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
