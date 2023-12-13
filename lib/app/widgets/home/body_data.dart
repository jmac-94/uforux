import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:forux/app/controllers/forum_controller.dart';
import 'package:forux/app/models/comment.dart';

class BodyData extends StatelessWidget {
  final Comment comment;

  const BodyData({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ).copyWith(
            bottom: 5,
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              comment.title,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              comment.description,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              maxLines: 5,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
        if (comment.hasImages())
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 8.0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FutureBuilder<Widget>(
                future: Future.value(createCarousel()),
                builder:
                    (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return snapshot.data!;
                  }
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget createCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 300,
        enableInfiniteScroll: false,
      ),
      items: comment.attachments['images']?.map((attachment) {
            return FutureBuilder<Image>(
              future: ForumController.fetchImage(attachment),
              builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 300,
                          child: Image(
                            image: snapshot.data!.image,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ],
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
