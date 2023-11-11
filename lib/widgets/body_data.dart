import 'package:flutter/widgets.dart';
import 'package:uforuxpi3/models/comment.dart';

class BodyData extends StatelessWidget {
  final String imageUrl2;
  final bool isImage;
  final String text;
  final Comment comment;

  const BodyData(
      {super.key,
      required this.imageUrl2,
      required this.isImage,
      required this.text,
      required this.comment});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        isImage
            ? Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 20,
                  ),
                  child: Text(
                    comment.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            : const SizedBox(),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(12),
          ),
          child: isImage
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl2,
                        height: 250,
                        width: 270,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        comment.text,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
