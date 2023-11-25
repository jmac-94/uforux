import 'package:flutter/material.dart';

class ForumHeader extends StatelessWidget {
  const ForumHeader({
    super.key,
    required this.profilePhoto,
    required this.name,
    required this.realTime,
  });

  final String profilePhoto;
  final String name;
  final String realTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        //color: Colors.blue[100],
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
              name,
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
          const Text(
            '#MATH',
            style: TextStyle(
              fontSize: 11,
              color: Colors.blueAccent,
            ),
          ),
          const Spacer(),
          Text(
            realTime,
            style: const TextStyle(
              fontSize: 11,
            ),
          ),
        ]),
      ),
    );
  }
}
