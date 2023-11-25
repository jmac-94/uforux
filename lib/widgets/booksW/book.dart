import 'package:flutter/material.dart';

class CardBook extends StatelessWidget {
  final Color color;
  final String image;
  final IconData icon;
  const CardBook({
    super.key,
    required this.color,
    required this.image,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
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
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: color,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20.0,
            ),
          ),
        ),
      ],
    );
  }
}
