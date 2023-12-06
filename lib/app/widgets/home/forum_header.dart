import 'package:flutter/material.dart';
import 'package:uforuxpi3/app/models/comment.dart';

class ForumHeader extends StatelessWidget {
  final String profilePhoto;
  final Comment comment;

  const ForumHeader({
    super.key,
    required this.profilePhoto,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
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
              profilePhoto,
              width: 25,
              height: 25,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              comment.author?.username ?? '',
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ),
          const Text(
            'desde ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w200,
            ),
          ),
          Text(
            '#${comment.labels[0]}',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.blueAccent,
            ),
          ),
          const Spacer(),
        ]),
      ),
    );
  }
}
