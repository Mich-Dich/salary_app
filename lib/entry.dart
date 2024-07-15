import 'dart:convert';

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
}

List<Entry> parseEntries(String jsonString) {
  final parsed = jsonDecode(jsonString).cast<Map<String, dynamic>>();
  return parsed.map<Entry>((json) => Entry.fromJson(json)).toList();
}

String serializeEntries(List<Entry> entries) {
  return jsonEncode(entries.map((entry) => entry.toJson()).toList());
}
