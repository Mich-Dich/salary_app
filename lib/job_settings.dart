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
  
  TimeOfDay work_duration_min = TimeOfDay(hour: 6, minute: 0);    // minimum amount of time to work acording to contract
  TimeOfDay work_duration_max = TimeOfDay(hour: 8, minute: 0);    // maximum amount of time to work bevor being worned
}
