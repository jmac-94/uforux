import 'package:flutter/material.dart';
import 'package:forux/app/models/comment.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:forux/core/utils/extensions.dart';

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
        child: Row(
          children: [
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
                comment.author?.username.toString().capitalize() ?? '',
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
            Flexible(
              child: Text(
                ' ${comment.labels[0]}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.blueAccent,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Text(
              timeago.format(comment.createdAt.toDate()),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
