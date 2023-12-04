import 'package:flutter/material.dart';
import 'package:uforuxpi3/app/widgets/authentication/sign_in_form.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  const SignIn({super.key, required this.toggleView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/images/loginback.png",
            ),
            opacity: 0.9,
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                child: Center(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: SingleChildScrollView(
                      child: SignInForm(toggleView: widget.toggleView),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
