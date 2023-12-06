import 'package:flutter/material.dart';

class Constants {
  static const String appName = 'Forux';

  static const InputDecoration textInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 2.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2.0),
    ),
  );

  static const List<String> degrees = [
    'ingeniería civil',
    'ingeniería industrial',
    'ingeniería de la energía',
    'ingeniería química',
    'ingeniería mecánica',
    'ingeniería electrónica',
    'ingeniería ambiental',
    'ciencia de la computación',
    'ingeniería mecatrónica',
    'bioingeniería',
    'administración y negocios digitales',
    'ciencia de datos'
  ];

  static const List<String> courses = [
    'cálculo de una variable',
    'laboratorio de comunicación 1',
    'proyectos interdisciplinarios 1',
    'proyectos interdisciplinarios 2',
    'proyectos interdisciplinarios 3',
    'álgebra lineal',
    'base de datos 1',
    'base de datos 2',
  ];

  static const List<String> coursesAcronyms = [
    'C1V',
    'LabComu1',
    'PI1',
    'PI2',
    'PI3',
    'ADA',
    'BD1',
    'BD2',
  ];

  static const List<String> labels = [
    ...coursesAcronyms,
    ...degrees,
    ...courses,
    'Futter',
    'Dart',
    'Firebase',
    'UI/UX',
    'Backend',
    'Frontend',
    'general',
  ];
}
