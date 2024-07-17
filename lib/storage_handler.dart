// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures

import 'dart:core';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'entry.dart';

class StorageHandler {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/entries.json');
  }

  Future<List<Entry>> readEntries() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        String contents = await file.readAsString();
        List<dynamic> jsonEntries = jsonDecode(contents);
        List<Entry> entries = jsonEntries.map((entry) => Entry.fromJson(entry)).toList();
        return entries;
      } else {
        return [];
      }
    } catch (e) {
      print('Error reading entries: $e');
      return [];
    }
  }

  Future<File> writeEntries(List<Entry> entries) async {

    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();

    // Sort entries by date
    entries.sort((a, b) => a.date.compareTo(b.date));

    // Recalculate amount for each entry
    for (var entry in entries) 
      entry.amount = entry.calculateAmount();

    final file = await _localFile;
    List<Map<String, dynamic>> jsonEntries = entries.map((entry) => entry.toJson()).toList();
    String json = jsonEncode(jsonEntries);

    stopwatch.stop();
    Duration elapsed = stopwatch.elapsed;
    print('Elapsed time: ${elapsed.inMilliseconds} milliseconds');

    return file.writeAsString(json);
  }
}