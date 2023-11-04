import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/screens/authentication/authentication.dart';
import 'package:uforuxpi3/screens/home/main_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AppUser? user = Provider.of<AppUser?>(context);

    if (user == null) {
      return const Authentication();
    }
    return MainScreen(user: user);
  }
}
