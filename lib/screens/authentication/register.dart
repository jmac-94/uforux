import 'package:flutter/material.dart';
import 'package:uforuxpi3/services/auth.dart';
import 'package:uforuxpi3/util/const.dart';
import 'package:uforuxpi3/util/extensions.dart';
import 'package:uforuxpi3/util/validations.dart';
import 'package:uforuxpi3/widgets/custom_button.dart';
import 'package:uforuxpi3/widgets/custom_text_field.dart';
import 'package:uforuxpi3/widgets/dropdown_button_more_width.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  const Register({super.key, required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

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

  buildForm() {
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
