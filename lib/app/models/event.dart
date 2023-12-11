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
