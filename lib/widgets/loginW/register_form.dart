import 'package:flutter/material.dart';
import 'package:uforuxpi3/services/auth.dart';
import 'package:uforuxpi3/util/const.dart';
import 'package:uforuxpi3/util/extensions.dart';
import 'package:uforuxpi3/util/validations.dart';
import 'package:uforuxpi3/widgets/loginW/custom_button.dart';
import 'package:uforuxpi3/widgets/loginW/custom_text_field.dart';
import 'package:uforuxpi3/widgets/loginW/dropdown_button_more_width.dart';

class RegisterForm extends StatefulWidget {
  final Function toggleView;

  const RegisterForm({super.key, required this.toggleView});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  bool loading = false;
  String error = '';

  String email = '';
  String username = '';
  String password = '';
  String entrySemester = '';
  bool assesor = false;
  String degree = '';

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
          child: buildRegisterForm(),
        ),
        const SizedBox(height: 20.0),
        buildRegisterButton(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¿Ya tienes una cuenta?',
              style: TextStyle(
                color: Color.fromARGB(255, 234, 233, 233),
                fontSize: 15,
              ),
            ),
            TextButton(
              onPressed: () {
                // cambiar vista a signin
                setState(() {
                  widget.toggleView();
                });
              },
              child: const Text(
                'Iniciar sesión',
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

  buildRegisterForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CustomTextField(
          enabled: !loading,
          hintText: "Correo",
          textInputAction: TextInputAction.next,
          validateFunction: Validations.validateEmail,
          onChange: (String? val) {
            email = val ?? '';
          },
        ).fadeInList(1, false),
        Column(
          children: <Widget>[
            const SizedBox(height: 20.0),
            CustomTextField(
              enabled: !loading,
              hintText: "Nombre de usuario",
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateUsername,
              onChange: (String? val) {
                username = val ?? '';
              },
            ),
            const SizedBox(height: 20.0),
            CustomTextField(
              enabled: !loading,
              hintText: "Contraseña",
              textInputAction: TextInputAction.done,
              validateFunction: Validations.validatePassword,
              obscureText: true,
              onChange: (String? val) {
                password = val ?? '';
              },
            ),
            const SizedBox(height: 20.0),
            CustomTextField(
              enabled: !loading,
              hintText: "Ciclo de ingreso",
              textInputAction: TextInputAction.done,
              validateFunction: Validations.validateSemester,
              textInputType: TextInputType.datetime,
              onChange: (String? val) {
                entrySemester = val ?? '';
              },
            ),
            const SizedBox(height: 20.0),
            CustomDropdownField(
              items: const ['Sí', 'No'],
              hintText: '¿Eres asesor?',
              onChanged: (value) {},
              validator: Validations.validateYesOrNo,
              onSaved: (value) {
                assesor = value == 'Sí';
              },
            ),
            const SizedBox(height: 20.0),
            CustomDropdownField(
              items: degrees,
              hintText: 'Carrera',
              onChanged: (value) {},
              validator: Validations.validateDegree,
              onSaved: (value) {
                degree = value ?? '';
              },
            ),
          ],
        ).fadeInList(2, false),
      ],
    );
  }

  buildRegisterButton() {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : CustomButton(
            label: "Registrarse",
            onPressed: register,
          ).fadeInList(4, false);
  }

  Future<void> register() async {
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      dynamic result = await _auth.registerWithEmailAndPassword(
          email: email,
          username: username,
          password: password,
          entrySemester: entrySemester,
          assesor: assesor,
          degree: degree);

      if (result == null) {
        setState(() {
          error = 'Please supply valid email or password';
        });
      }
    }
  }
}
