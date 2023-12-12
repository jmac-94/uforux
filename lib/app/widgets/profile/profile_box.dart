import 'package:flutter/material.dart';

class ProfileBox extends StatelessWidget {
  final String path;
  final String carrera;
  const ProfileBox({
    super.key,
    required this.path,
    required this.carrera,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: Colors.blueAccent[700],
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(
                path,
              ),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Text(
          carrera,
          maxLines: 4,
          style: const TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
