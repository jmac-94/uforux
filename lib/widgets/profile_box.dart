import 'package:flutter/material.dart';

class ProfileBox extends StatelessWidget {
  final String path;
  final String carrera;
  const ProfileBox({super.key, required this.path, required this.carrera});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 85,
          height: 85,
          decoration: BoxDecoration(
            color: Colors.redAccent,
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
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
