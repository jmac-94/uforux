import 'package:flutter/material.dart';

class Constants {
  static String appName = 'Forux';
}

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue, width: 2.0),
  ),
);

final List<String> degrees = [
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
