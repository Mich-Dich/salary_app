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

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final eveningBeginMinutes =
        jobSettings.eveningBeginTime.hour * 60 + jobSettings.eveningBeginTime.minute;
    final nightBeginMinutes =
        jobSettings.nightBeginTime.hour * 60 + jobSettings.nightBeginTime.minute;

    double totalAmount = 0.0;

    for (int minute = startMinutes; minute < endMinutes; minute++) {
      int currentHour = (minute ~/ 60) % 24;
      int currentMinute = minute % 60;

      if (minute >= nightBeginMinutes) {
        totalAmount += jobSettings.nightHourlyRate / 60;
      } else if (minute >= eveningBeginMinutes) {
        totalAmount += jobSettings.eveningHourlyRate / 60;
      } else {
        totalAmount += jobSettings.hourlyRate / 60;
      }
    }

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
