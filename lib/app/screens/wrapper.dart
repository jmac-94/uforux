import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:forux/app/models/app_user.dart';
import 'package:forux/app/screens/authentication/authentication.dart';
import 'package:forux/app/screens/main_screen/main_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppUser? user = Provider.of<AppUser?>(context);

    if (user == null) {
      return const Authentication();
    }
    return MainScreen(user: user);
  }
}
