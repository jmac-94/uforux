class Validations {
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre de usuario es requerido.';
    }
    final RegExp nameExp =
        RegExp(r'^[A-Za-zğüşöçİĞÜŞÖÇ][A-Za-zğüşöçİĞÜŞÖÇ0-9 ]*$');

    if (!nameExp.hasMatch(value)) {
      return 'Por favor, solo ingresar caracteres alfabéticos.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresar un correo.';
    }
    final RegExp nameExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,2"
        r"53}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-z"
        r"A-Z0-9])?)*$");
    if (!nameExp.hasMatch(value)) return 'Correo invalido';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty || value.length < 6) {
      return 'Por favor, ingresar una contraseña válida.';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre de usuario es requerido.';
    }

    return null;
  }

  static String? validateSemester(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresar el ciclo de ingreso.';
    }
    final RegExp semesterExp = RegExp(r'^\d{4}-(1|2)$');

    if (!semesterExp.hasMatch(value)) {
      return 'Formato de ciclo invalido. Formato esperado:\nYYYY-1 o YYYY-2';
    }

    return null;
  }

  static String? validateYesOrNo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, solo ingresa sí o no.';
    }
    if (value.toLowerCase() == 'sí' ||
        value.toLowerCase() == 'si' ||
        value.toLowerCase() == 'no') {
      return null;
    } else {
      return 'Por favor, solo ingresa sí o no.';
    }
  }

  static String? validateYearsTeaching(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa un número entero.';
    }

    try {
      int intValue = int.parse(value);

      if (intValue < 0 || intValue > 70) {
        return 'Por favor, ingresa un número entre 0 y 70.';
      }

      return null;
    } catch (e) {
      return 'Por favor, ingresa un número entero.';
    }
  }

  static String? validateDegree(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa una carrera.';
    }

    return null;
  }
}
