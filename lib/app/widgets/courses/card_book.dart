import 'package:flutter/material.dart';
import 'package:uforuxpi3/app/widgets/courses/forum_view.dart';

class CardBook extends StatelessWidget {
  final Color color;
  final String image;
  final String title;

  const CardBook({
    super.key,
    required this.color,
    required this.image,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(title: title)),
        );
      },
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.width * 0.47,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(image),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            height: 30,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
