import 'package:flutter/material.dart';
import 'package:uforuxpi3/screens/authentication/register.dart';
import 'package:uforuxpi3/screens/authentication/sign_in.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

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
    if (showSignIn) {
      return SignIn(toggleView: toggleView);
    }
    return Register(toggleView: toggleView);
  }
}
