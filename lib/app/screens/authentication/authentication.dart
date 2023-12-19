import 'package:flutter/material.dart';

import 'package:forux/app/screens/authentication/register.dart';
import 'package:forux/app/screens/authentication/sign_in.dart';

class Authentication extends StatefulWidget {
  const Authentication({
    super.key,
  });

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  bool showSignIn = true;

  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showSignIn
        ? SignIn(toggleView: toggleView)
        : Register(toggleView: toggleView);
  }
}
