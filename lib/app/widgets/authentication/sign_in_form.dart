import 'package:flutter/material.dart';

import 'package:forux/app/controllers/authentication_controller.dart';
import 'package:forux/app/models/app_user.dart';
import 'package:forux/core/utils/const.dart';
import 'package:forux/core/utils/extensions.dart';
import 'package:forux/core/utils/validations.dart';
import 'package:forux/app/widgets/authentication/custom_button.dart';
import 'package:forux/app/widgets/authentication/custom_text_field.dart';

class SignInForm extends StatefulWidget {
  final Function toggleView;

  const SignInForm({
    super.key,
    required this.toggleView,
  });

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthenticationController();

  bool loading = false;
  String error = '';

  // User data
  String email = '';
  String password = '';

  Future<void> signIn() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }
    formState.save();

    final AppUser? result =
        await _auth.signInWithEmailAndPassword(email, password);
    if (result == null) {
      setState(() {
        error =
            'No se pudo iniciar sesión. Por favor ingrese un correo o contraseña válidos.';
      });
    }
  }

  Widget buildSignInForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CustomTextField(
          enabled: !loading,
          hintText: 'Correo',
          textInputAction: TextInputAction.next,
          validateFunction: Validations.validateEmail,
          onSaved: (String? val) {
            email = val ?? '';
          },
        ).fadeInList(1, false),
        const SizedBox(height: 20.0),
        CustomTextField(
          enabled: !loading,
          hintText: 'Contraseña',
          textInputAction: TextInputAction.done,
          validateFunction: Validations.validatePassword,
          obscureText: true,
          onSaved: (String? val) {
            password = val ?? '';
          },
        ).fadeInList(2, false),
      ],
    );
  }

  Widget buildSignInButton() {
    return loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : CustomButton(
            label: 'Iniciar Sesión',
            onPressed: signIn,
          ).fadeInList(4, false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // App name
        const Text(
          Constants.appName,
          style: TextStyle(
            fontSize: 70.0,
            fontWeight: FontWeight.bold,
          ),
        ).fadeInList(0, false),
        const SizedBox(height: 20.0),
        // Form
        Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: buildSignInForm(),
        ),
        const SizedBox(height: 20.0),
        buildSignInButton(),
        const SizedBox(height: 20.0),
        // Cambiar de vista a Register
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No tienes una cuenta?',
              style: TextStyle(
                color: Color.fromARGB(255, 234, 233, 233),
                fontSize: 15,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.toggleView();
                });
              },
              child: const Text(
                'Regístrate',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 4, 14),
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ).fadeInList(5, false),
        const SizedBox(height: 12.0),
        // Mensaje de error
        error.isNotEmpty
            ? Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14.0,
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
