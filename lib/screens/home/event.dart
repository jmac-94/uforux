import 'package:flutter/material.dart';

class Event {
  final String title;
  TimeOfDay starTime;
  TimeOfDay endtime;

  Event(this.title, this.starTime, this.endtime);
}
