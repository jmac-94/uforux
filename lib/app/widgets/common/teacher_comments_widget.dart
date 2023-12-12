import 'package:flutter/material.dart';

class TeacherCommentsWidget extends StatelessWidget {
  const TeacherCommentsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1630332458166-1c3bdde17665?q=80&w=3540&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
            height: 350,
            width: 350,
          ),
        ],
      ),
    );
  }
}
