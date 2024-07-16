// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'entry.dart';
import 'storage_handler.dart';
import 'add_entry_dialog.dart';
import 'util.dart';

void main() {
  runApp(SalaryCalculatorApp());
}

class SalaryCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salary Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue[800], // Dark blue as primary color
        highlightColor: Colors.blue[400], // Lighter blue as accent color
        textTheme:  const TextTheme(
          titleLarge: TextStyle(color: Colors.white), // Text color for app bar title
          titleMedium: TextStyle(color: Colors.white), // Text color for list item title
          titleSmall: TextStyle(color: Colors.white70), // Text color for list item subtitle
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue[800], // Dark blue for FAB background
          foregroundColor: Colors.white, // White for FAB text/icon color
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue[800]), // Dark blue for ElevatedButton background
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.blue[400]), // Lighter blue for TextButton text color
          ),
        ),
        appBarTheme: AppBarTheme(
          color: Colors.blue[800], // Dark blue for app bar background
          titleTextStyle: const TextStyle(
            color: Colors.white, // White text color for app bar title
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: SalaryCalculatorHomePage(),
    );
  }
}

class SalaryCalculatorHomePage extends StatefulWidget {
  @override
  _SalaryCalculatorHomePageState createState() => _SalaryCalculatorHomePageState();
}

class _SalaryCalculatorHomePageState extends State<SalaryCalculatorHomePage> {
  final StorageHandler storageHandler = StorageHandler();
  List<Entry> entries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final loadedEntries = await storageHandler.readEntries();
      setState(() {
        entries = loadedEntries;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading entries: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Calculator'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : entries.isEmpty
              ? const Center(child: Text('No entries yet'))
              : _buildEntriesList(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: _openAddEntryPopup,
              child: const Text('+', style: TextStyle(fontSize: 22),),
            ),
            FloatingActionButton(
              onPressed: _handleFloatingActionButton,
              child: Text(_floatingActionButtonText()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntriesList() {
    // Group entries by month and day
    Map<String, Map<int, List<Entry>>> groupedEntries = {};

    for (var entry in entries) {
      String month = DateFormat.MMMM().format(entry.date);
      int day = entry.date.day;

      if (!groupedEntries.containsKey(month))
        groupedEntries[month] = {};

      if (!groupedEntries[month]!.containsKey(day))
        groupedEntries[month]![day] = [];

      groupedEntries[month]![day]!.add(entry);
    }

    // Build the list view
    return ListView.builder(
      itemCount: groupedEntries.length,
      itemBuilder: (context, monthIndex) {
        String month = groupedEntries.keys.elementAt(monthIndex);
        Map<int, List<Entry>> entriesByDay = groupedEntries[month]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                month,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            Column(
              children: entriesByDay.keys.map((day) {
                List<Entry> entriesOfDay = entriesByDay[day]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        day.toString(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Column(
                      children: entriesOfDay.map((entry) => ListTile(
                        title: Text(
                          'Time: ${DateFormat.Hm().format(entry.startTime)} ${entry.endTime == entry.startTime ? '---' : '- ${DateFormat.Hm().format(entry.endTime)}'}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text('Amount: \$${entry.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () => _editEntry(entry),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteEntry(entries.indexOf(entry)),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  void _editEntry(Entry entry) {
    // Create a copy of the entry to edit
    Entry editedEntry = Entry.clone(entry);

    // Initialize variables with existing entry details
    DateTime selectedStartTime = editedEntry.startTime;
    DateTime selectedEndTime = editedEntry.endTime;

    // Show dialog for editing entry details
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Entry"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date picker
              const Text("Date:", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: editedEntry.date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null && picked != editedEntry.date) {
                      setState(() {
                        editedEntry.date = picked;
                      });
                    }
                  },
                  child: Text(DateFormat.yMd().format(editedEntry.date)),
                ),
              ),
              const SizedBox(height: 16),

              // Start Time picker
              const Text("Start Time:", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? picked = await showDialog<TimeOfDay>(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomTimePicker(initialTime: TimeOfDay(hour: selectedStartTime.hour, minute: selectedStartTime.minute));
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        selectedStartTime = DateTime(
                          editedEntry.date.year,
                          editedEntry.date.month,
                          editedEntry.date.day,
                          picked.hour,
                          picked.minute,
                        );
                        editedEntry.startTime = selectedStartTime;                        
                      });
                    }
                  },
                  child: Text(DateFormat.Hm().format(selectedStartTime)),
                ),
              ),
              const SizedBox(height: 16),

              // End Time picker
              const Text("End Time:", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? picked = await showDialog<TimeOfDay>(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomTimePicker(initialTime: TimeOfDay(hour: selectedEndTime.hour, minute: selectedEndTime.minute));
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        selectedEndTime = DateTime(
                          editedEntry.date.year,
                          editedEntry.date.month,
                          editedEntry.date.day,
                          picked.hour,
                          picked.minute,
                        );
                      });
                    }
                  },
                  child: Text(DateFormat.Hm().format(selectedEndTime)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Update entry details
                editedEntry.startTime = selectedStartTime;
                editedEntry.endTime = selectedEndTime;
                entry.calculateAmount();

                // Replace old entry with edited entry in list
                setState(() {
                  int index = entries.indexOf(entry);
                  entries[index] = editedEntry;
                  storageHandler.writeEntries(entries);
                });

                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }



  void _handleFloatingActionButton() {
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);
    final entryIndex = entries.indexWhere((entry) => entry.date == currentDate);
    if (entryIndex != -1) {
      _stopEntry();
    } else {
      _startEntry();
    }
  }

  void _startEntry() {
    final now = DateTime.now();
    final newEntry = Entry(
      date: DateTime(now.year, now.month, now.day),
      startTime: now,
      endTime: now,
      amount: 0.0,
    );

    setState(() {
      entries.add(newEntry);
      storageHandler.writeEntries(entries);
    });
  }

  void _stopEntry() {
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);

    final entryIndex = entries.indexWhere((entry) => entry.date == currentDate);
    if (entryIndex != -1) {
      final entry = entries[entryIndex];
      entry.endTime = now;
      entry.calculateAmount();

      setState(() {
        storageHandler.writeEntries(entries);
      });
    }
  }

  void _deleteEntry(int index) {
    setState(() {
      entries.removeAt(index);
      storageHandler.writeEntries(entries);
    });
  }

  void _openAddEntryPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddEntryDialog(
          onEntryAdded: (DateTime selectedDate, TimeOfDay selectedStartTime, TimeOfDay selectedEndTime) {
            _addNewEntry(selectedDate, selectedStartTime, selectedEndTime);
          },
        );
      },
    );
  }

  void _addNewEntry(DateTime selectedDate, TimeOfDay selectedStartTime, TimeOfDay selectedEndTime) {

    final DateTime startTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedStartTime.hour,
      selectedStartTime.minute,
    );

    final DateTime endTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedEndTime.hour,
      selectedEndTime.minute,
    );

    final newEntry = Entry(
      date: selectedDate,
      startTime: startTime,
      endTime: endTime,
      amount: 0,
    );

    newEntry.calculateAmount();

    setState(() {
      entries.add(newEntry);
      storageHandler.writeEntries(entries);
    });
  }

  String _floatingActionButtonText() {
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);
    final entryIndex = entries.indexWhere((entry) => entry.date == currentDate);
    return entryIndex != -1 ? 'STOP' : 'START';
  }
}
