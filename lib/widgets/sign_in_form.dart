import 'package:flutter/material.dart';
import 'package:uforuxpi3/services/auth.dart';
import 'package:uforuxpi3/util/const.dart';
import 'package:uforuxpi3/util/extensions.dart';
import 'package:uforuxpi3/util/validations.dart';
import 'package:uforuxpi3/widgets/custom_button.dart';
import 'package:uforuxpi3/widgets/custom_text_field.dart';

class SignInForm extends StatefulWidget {
  final Function toggleView;

  const SignInForm({super.key, required this.toggleView});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  bool loading = false;
  String error = '';

  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          Constants.appName,
          style: const TextStyle(
            fontSize: 70.0,
            fontWeight: FontWeight.bold,
          ),
        ).fadeInList(0, false),
        const SizedBox(height: 50.0),
        Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: buildSignInForm(),
        ),
        Column(
          children: [
            const SizedBox(height: 10.0),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {}, // falta agregar ventana.
                //formMode = FormMode.FORGOT_PASSWORD;
                // setState(() {}
                child: const Text(
                  '¿Olvidó la contraseña?',
                  style: TextStyle(
                    color: Color.fromARGB(255, 234, 233, 233),
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ).fadeInList(3, false),
        const SizedBox(height: 20.0),
        buildSignInButton(),
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
                // cambiar vista a registro
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
        Text(
          error,
          style: const TextStyle(color: Colors.red, fontSize: 14.0),
        )
      ],
    );
  }

  buildSignInForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CustomTextField(
          enabled: !loading,
          hintText: "Correo",
          textInputAction: TextInputAction.next,
          validateFunction: Validations.validateEmail,
          onSaved: (String? val) {
            email = val ?? '';
          },
        ).fadeInList(1, false),
        Column(
          children: <Widget>[
            const SizedBox(height: 20.0),
            CustomTextField(
              enabled: !loading,
              hintText: "Contraseña",
              textInputAction: TextInputAction.done,
              validateFunction: Validations.validatePassword,
              submitAction: signIn,
              obscureText: true,
              onSaved: (String? val) {
                password = val ?? '';
              },
            ),
          ],
        ).fadeInList(2, false),
      ],
    );
  }

  buildSignInButton() {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : CustomButton(
            label: "Iniciar Sesión",
            onPressed: signIn,
          ).fadeInList(4, false);
  }

  Future<void> signIn() async {
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      dynamic result = await _auth.signInWithEmailAndPassword(email, password);
      if (result == null) {
        setState(() {
          error =
              'No se pudo iniciar sesión. Por favor ingrese un correo o contraseña válidos.';
        });
      }
    }
  }
}
