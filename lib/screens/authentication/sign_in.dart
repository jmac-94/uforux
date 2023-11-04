import 'package:flutter/material.dart';
import 'package:uforuxpi3/services/auth.dart';
import 'package:uforuxpi3/util/const.dart';
import 'package:uforuxpi3/util/extensions.dart';
import 'package:uforuxpi3/util/validations.dart';
import 'package:uforuxpi3/widgets/custom_button.dart';
import 'package:uforuxpi3/widgets/custom_text_field.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn({required this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  String error = '';

  String email = '';
  String password = '';

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
                      child: buildFormContainer(),
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

  buildFormContainer() {
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
          child: buildForm(),
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

  buildForm() {
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
              submitAction: login,
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
            onPressed: login,
          ).fadeInList(4, false);
  }

  Future<void> login() async {
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      dynamic result = await _auth.signInWithEmailAndPassword(email, password);
      if (result == null) {
        setState(() {
          error = 'Could not sign in. Please supply valid email or password';
        });
      }
    }
  }
}
