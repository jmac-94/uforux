import 'package:flutter/material.dart';

import 'package:forux/app/controllers/authentication_controller.dart';
import 'package:forux/app/models/app_user.dart';
import 'package:forux/core/utils/const.dart';
import 'package:forux/core/utils/extensions.dart';
import 'package:forux/core/utils/validations.dart';
import 'package:forux/app/widgets/authentication/custom_button.dart';
import 'package:forux/app/widgets/authentication/custom_text_field.dart';
import 'package:forux/app/widgets/authentication/dropdown_button_more_width.dart';

class RegisterForm extends StatefulWidget {
  final Function toggleView;

  const RegisterForm({
    super.key,
    required this.toggleView,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthenticationController();

  bool loading = false;
  String error = '';

  // User data
  String email = '';
  String password = '';
  String username = '';
  String name = '';
  String entrySemester = '';
  bool assesor = false;
  String degree = '';
  String aboutMe = '';

  Future<void> register() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }
    formState.save();

    AppUser? result = await _auth.registerWithEmailAndPassword(
      email: email,
      password: password,
      username: username,
      name: name,
      entrySemester: entrySemester,
      assesor: assesor,
      degree: degree,
      aboutMe: aboutMe,
    );
    if (result == null) {
      setState(() {
        error =
            'No se pudo registrar. Por favor, ingresa un correo y/o contraseña válidos.';
      });
    }
  }

  buildRegisterButton() {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : CustomButton(
            label: 'Registrarse',
            onPressed: register,
          ).fadeInList(4, false);
  }

  buildRegisterForm() {
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
        ).fadeInList(1, false),
        const SizedBox(height: 20.0),
        Column(
          children: <Widget>[
            CustomTextField(
              enabled: !loading,
              hintText: 'Nombre',
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateName,
              onSaved: (String? val) {
                name = val ?? '';
              },
            ),
            const SizedBox(height: 20.0),
            CustomTextField(
              enabled: !loading,
              hintText: 'Nombre de usuario',
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateUsername,
              onSaved: (String? val) {
                username = val ?? '';
              },
            ),
            const SizedBox(height: 20.0),
            CustomTextField(
              enabled: !loading,
              hintText: 'Ciclo de ingreso',
              textInputAction: TextInputAction.done,
              validateFunction: Validations.validateSemester,
              textInputType: TextInputType.datetime,
              onSaved: (String? val) {
                entrySemester = val ?? '';
              },
            ),
            const SizedBox(height: 20.0),
            CustomDropdownField(
              items: const ['Sí', 'No'],
              hintText: '¿Eres asesor?',
              validator: Validations.validateYesOrNo,
              onSaved: (val) {
                assesor = val == 'Sí';
              },
            ),
            const SizedBox(height: 20.0),
            CustomDropdownField(
              items: Constants.degrees,
              hintText: 'Carrera',
              validator: Validations.validateDegree,
              onSaved: (val) {
                degree = val ?? '';
              },
            ),
            const SizedBox(height: 20.0),
            CustomTextField(
              enabled: !loading,
              hintText: 'Acerca de mí',
              maxLines: null,
              textInputType: TextInputType.multiline,
              onSaved: (String? val) {
                aboutMe = val ?? '';
              },
            ),
          ],
        ).fadeInList(2, false),
      ],
    );
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
        const SizedBox(height: 50.0),
        // Form
        Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: buildRegisterForm(),
        ),
        const SizedBox(height: 20.0),
        buildRegisterButton(),
        // Cambiar vista a SignIn
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
        // Mensaje de error
        Text(
          error,
          style: const TextStyle(color: Colors.red, fontSize: 14.0),
        )
      ],
    );
  }
}
