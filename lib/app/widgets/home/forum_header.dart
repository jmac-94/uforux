import 'package:flutter/material.dart';
import 'package:forux/app/controllers/app_user_controller.dart';
import 'package:forux/app/models/app_user.dart';
import 'package:forux/app/models/comment.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:forux/core/utils/extensions.dart';

class ForumHeader extends StatelessWidget {
  final Comment comment;
  late AppUserController appUserController;

  ForumHeader({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    // InitState
    appUserController = AppUserController(uid: comment.userId);
    appUserController.appUser = AppUser(id: comment.userId);

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
              child: FutureBuilder<Image>(
                future: appUserController.getProfilePhoto(),
                builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Image(
                      image: snapshot.data!.image,
                      width: 25,
                      height: 25,
                      fit: BoxFit.cover,
                    );
                  }
                },
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
              timeago.format(
                comment.createdAt.toDate(),
                locale: 'es',
              ),
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
