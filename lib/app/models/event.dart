import 'package:flutter/material.dart';

class Event {
  final String title;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final DateTime date;

  Event({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'startTime': _timeOfDayToString(startTime),
      'endTime': _timeOfDayToString(endTime),
    };
  }

  static Event fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      date: DateTime.parse(json['date']),
      startTime: _stringToTimeOfDay(json['startTime']),
      endTime: _stringToTimeOfDay(json['endTime']),
    );
  }

  static String _timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static TimeOfDay _stringToTimeOfDay(String timeString) {
    final timeParts = timeString.split(':');
    return TimeOfDay(
        hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
  }
}

class EventType {
  static const String course = "Curso";
  static const String degree = "Carrera";
  static const String university = "Universidad";
  static const String other = "Otros";
}
