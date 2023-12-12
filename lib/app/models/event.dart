import 'package:flutter/material.dart';

class Event {
  final String title;
  TimeOfDay startTime;
  TimeOfDay endTime;

  Event({
    required this.title,
    required this.startTime,
    required this.endTime,
  });
}

class EventType {
  static const String course = "Curso";
  static const String degree = "Carrera";
  static const String university = "Universidad";
  static const String other = "Otros";
}
