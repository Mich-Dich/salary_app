import 'package:flutter/material.dart';

class JobSettings {
  static final JobSettings _instance = JobSettings._internal();

  factory JobSettings() {
    return _instance;
  }

  JobSettings._internal();

  double hourlyRate = 12.63;
  double eveningHourlyRate = 15.156; // 20% increase
  double nightHourlyRate = 18.945; // 50% increase
  TimeOfDay eveningBeginTime = TimeOfDay(hour: 18, minute: 0);
  TimeOfDay nightBeginTime = TimeOfDay(hour: 20, minute: 0);
}
