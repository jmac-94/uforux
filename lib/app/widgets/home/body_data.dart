import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:uforuxpi3/app/controllers/forum_controller.dart';
import 'package:uforuxpi3/app/models/comment.dart';

class BodyData extends StatelessWidget {
  final Comment comment;
  final ForumController forumController;

  const BodyData({
    super.key,
    required this.comment,
    required this.forumController,
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
              style: TextStyle(
                color: Colors.grey[500],
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
        Row(
          children: comment.labels.map((label) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(label),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
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
              future: forumController.fetchImage(attachment),
              builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
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
