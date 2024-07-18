// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'entry.dart';
import 'storage_handler.dart';
import 'add_entry_dialog.dart';
import 'edit_entry_dialog.dart';

void main() {
  runApp(SalaryCalculatorApp());
}

class SalaryCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salary Calculator',
      debugShowCheckedModeBanner: false,  // Disable the debug banner
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
    Map<String, Map<int, List<Entry>>> groupedEntries = {};

    for (var entry in entries) {
      String month = DateFormat.MMMM().format(entry.date);
      int week = ((entry.date.day - 1) ~/ 7) + 1;

      if (!groupedEntries.containsKey(month))
        groupedEntries[month] = {};

      if (!groupedEntries[month]!.containsKey(week))
        groupedEntries[month]![week] = [];

      groupedEntries[month]![week]!.add(entry);
    }

    String currentMonth = DateFormat.MMMM().format(DateTime.now());

    return ListView.builder(
      itemCount: groupedEntries.length,
      itemBuilder: (context, monthIndex) {
        String month = groupedEntries.keys.elementAt(monthIndex);
        Map<int, List<Entry>> entriesByWeek = groupedEntries[month]!;

        double totalAmountForMonth = 0;
        for (var entries in entriesByWeek.values)
          for (var entry in entries)
            totalAmountForMonth += entry.amount;

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16.0), // Spacing between months
              child: ExpansionTile(
                initiallyExpanded: month == currentMonth,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      month,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      '${totalAmountForMonth.toStringAsFixed(2)}€',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                children: entriesByWeek.keys.map((week) {
                  List<Entry> entriesOfWeek = entriesByWeek[week]!;
                  bool isExpanded = false;

                  double totalAmountForWeek = 0;
                  int totalMinutesForWeek = 0;
                  Set<int> daysWorked = {};
                  for (var entry in entriesOfWeek) {
                    totalAmountForWeek += entry.amount;
                    totalMinutesForWeek += entry.endTime.difference(entry.startTime).inMinutes;
                    daysWorked.add(entry.date.weekday);
                  }

                  int hours = totalMinutesForWeek ~/ 60;
                  int minutes = totalMinutesForWeek % 60;
                  String totalHoursForWeek = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

                  final eightHoursInMinutes = 8 * 60;
                  final workedMinutes = totalMinutesForWeek;
                  final differenceInMinutes = workedMinutes - eightHoursInMinutes;

                  String differenceText;
                  Color differenceColor;

                  if (differenceInMinutes > 0) {
                    differenceText = '-${formatDuration(Duration(minutes: differenceInMinutes))}';
                    differenceColor = Colors.red;
                  } else {
                    differenceText = formatDuration(Duration(minutes: -differenceInMinutes));
                    differenceColor = Colors.green;
                  }

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0), // Spacing between weeks
                        decoration: BoxDecoration(
                          color: isExpanded ? Colors.grey[800] : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Week $week',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Hours: $totalHoursForWeek ',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      const SizedBox(width: 4.0), // Add a small gap between texts
                                      Text(
                                        differenceText,
                                        style: TextStyle(color: differenceColor),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isExpanded ? Icons.remove : Icons.add,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isExpanded = !isExpanded;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: entriesOfWeek.map((entry) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${DateFormat.MMMd().format(entry.date)}: ${DateFormat.Hm().format(entry.startTime)} - ${DateFormat.Hm().format(entry.endTime)}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      '${entry.amount.toStringAsFixed(2)}€',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    Row(
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
                                  ],
                                ),
                              )).toList(),
                            ),
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: List.generate(7, (index) {
                                        int day = index + 1;
                                        bool worked = daysWorked.contains(day);
                                        String dayLabel = DateFormat.E().format(DateTime(2023, 1, day)).toUpperCase();

                                        return Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: worked ? Colors.grey : Colors.transparent,
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: Text(
                                            dayLabel,
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        Text(
                                          'Total hours: $totalHoursForWeek  ',
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                        Text(
                                          differenceText,
                                          style: TextStyle(color: differenceColor),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Total amount: ${totalAmountForWeek.toStringAsFixed(2)}€',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }


  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  void _editEntry(Entry entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditEntryDialog(
          entry: entry,
          onSave: (editedEntry) {
            setState(() {
              int index = entries.indexOf(entry);
              if (index != -1) {
                entries[index] = editedEntry;
                storageHandler.writeEntries(entries);
              }
            });
          },
        );
      },
    );
  }

  void _handleFloatingActionButton() {
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);
    final entryIndex = entries.indexWhere((entry) => entry.date == currentDate);
    if (entryIndex != -1) 
      _stopEntry();
    else 
      _startEntry();
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
      storageHandler.writeEntries(entries);

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
