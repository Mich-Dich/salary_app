// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'job_settings.dart';

class Entry {
  DateTime date;
  DateTime startTime;
  DateTime endTime;
  double amount;

  Entry({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.amount,
  });

  Entry.clone(Entry entry)
      : date = entry.date,
        startTime = entry.startTime,
        endTime = entry.endTime,
        amount = entry.amount;

  void update(DateTime startTime, DateTime endTime) {
    this.startTime = startTime;
    this.endTime = endTime;
    amount = calculateAmount();
  }

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      date: DateTime.parse(json['date']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'amount': amount,
    };
  }
  
  double calculateAmount() {
    final jobSettings = JobSettings();

    final DateTime startOfEvening = DateTime(
      date.year,
      date.month,
      date.day,
      jobSettings.eveningBeginTime.hour,
      jobSettings.eveningBeginTime.minute,
    );

    final DateTime startOfNight = DateTime(
      date.year,
      date.month,
      date.day,
      jobSettings.nightBeginTime.hour,
      jobSettings.nightBeginTime.minute,
    );

    double normalRate = jobSettings.hourlyRate / 60;
    double eveningRate = jobSettings.eveningHourlyRate / 60;
    double nightRate = jobSettings.nightHourlyRate / 60;

    // Calculate durations in minutes for each rate segment
    int normalMinutes = 0;
    int eveningMinutes = 0;
    int nightMinutes = 0;

    // Calculate duration from startTime to endTime
    int durationInMinutes = endTime.difference(startTime).inMinutes;

    // Determine minutes spent in each segment
    if (startTime.isBefore(startOfEvening) && endTime.isAfter(startOfEvening)) {
      normalMinutes += startOfEvening.difference(startTime).inMinutes;
      if (endTime.isBefore(startOfNight)) {
        eveningMinutes += endTime.difference(startOfEvening).inMinutes;
      } else {
        eveningMinutes += startOfNight.difference(startOfEvening).inMinutes;
        nightMinutes += endTime.difference(startOfNight).inMinutes;
      }
    } else if (startTime.isBefore(startOfNight) && endTime.isAfter(startOfNight)) {
      eveningMinutes += startOfNight.difference(startTime).inMinutes;
      nightMinutes += endTime.difference(startOfNight).inMinutes;
    } else
      normalMinutes += durationInMinutes;

    // Calculate amounts based on the calculated minutes and rates
    double totalAmount = normalMinutes * normalRate +
        eveningMinutes * eveningRate +
        nightMinutes * nightRate;

    amount = totalAmount;
    return totalAmount;
  }


}

List<Entry> parseEntries(String jsonString) {
  final parsed = jsonDecode(jsonString).cast<Map<String, dynamic>>();
  return parsed.map<Entry>((json) => Entry.fromJson(json)).toList();
}

String serializeEntries(List<Entry> entries) {
  return jsonEncode(entries.map((entry) => entry.toJson()).toList());
}
