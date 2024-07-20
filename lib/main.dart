// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, curly_braces_in_flow_control_structures

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'entry.dart';
import 'storage_handler.dart';
import 'add_entry_dialog.dart';
import 'edit_entry_dialog.dart';
import 'job_settings.dart';

void main() {
  JobSettings jobSettings = JobSettings();
  runApp(SalaryCalculatorApp(jobSettings: jobSettings));
}

class SalaryCalculatorApp extends StatelessWidget {

  final JobSettings jobSettings;

  SalaryCalculatorApp({required this.jobSettings});

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
    
    JobSettings jobSettings = JobSettings(); // Access the singleton instance

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openJobSettings,
          ),
        ],
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
  
  void _openJobSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return JobSettingsDialog();
      },
    ).then((value) => update_all_entries());
  }

    
  Widget _buildEntriesList() {
    Map<String, Map<int, List<Entry>>> groupedEntries = {};

    for (var entry in entries) {
      String month = DateFormat.MMMM().format(entry.date);
      int week = ((entry.date.day - 1) ~/ 7) + 1;

      if (!groupedEntries.containsKey(month)) groupedEntries[month] = {};

      if (!groupedEntries[month]!.containsKey(week)) groupedEntries[month]![week] = [];

      groupedEntries[month]![week]!.add(entry);
    }

    String currentMonth = DateFormat.MMMM().format(DateTime.now());

    return ListView.builder(
      itemCount: groupedEntries.length,
      itemBuilder: (context, monthIndex) {
        String month = groupedEntries.keys.elementAt(monthIndex);
        Map<int, List<Entry>> entriesByWeek = groupedEntries[month]!;

        double totalAmountForMonth = 0;
        for (var entries in entriesByWeek.values) {
          for (var entry in entries) {
            totalAmountForMonth += entry.amount;
          }
        }

        bool isMonthExpanded = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return ExpansionTile(
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
                  IconButton(
                    icon: Icon(
                      isMonthExpanded ? Icons.remove : Icons.add,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        isMonthExpanded = !isMonthExpanded;
                      });
                    },
                  ),
                ],
              ),
              children: [
                if (isMonthExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBarChartForMonth(entriesByWeek),
                      ],
                    ),
                  ),
                ...entriesByWeek.keys.map((week) {
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

                  JobSettings jobSettings = JobSettings(); // Access the singleton instance
                  final eightHoursInMinutes = (jobSettings.work_duration_max.hour * 60) + jobSettings.work_duration_max.minute;
                  final workedMinutes = totalMinutesForWeek;
                  final differenceInMinutes = workedMinutes - eightHoursInMinutes;

                  String differenceText;
                  Color differenceColor;

                  if (differenceInMinutes > 0) {
                    differenceText = 'Over limit by ${formatDuration(Duration(minutes: differenceInMinutes))}';
                    differenceColor = Colors.red;
                  } else {
                    differenceText = formatDuration(Duration(minutes: -differenceInMinutes));
                    differenceColor = Colors.green;
                  }

                  double weeklyGoalCompletion = (totalMinutesForWeek / eightHoursInMinutes) * 100;
                  weeklyGoalCompletion = weeklyGoalCompletion > 100 ? 100 : weeklyGoalCompletion;

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        decoration: isExpanded
                            ? BoxDecoration(
                                color: const Color.fromARGB(255, 34, 34, 34),
                                borderRadius: BorderRadius.circular(10.0),
                              )
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
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
                                      const SizedBox(width: 4.0),
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
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${DateFormat.MMMd().format(entry.date)}   ${DateFormat.Hm().format(entry.startTime)} ${(entry.endTime == entry.startTime) 
                                        ? ' ---       ' 
                                        : '- ${DateFormat.Hm().format(entry.endTime)}' }',
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
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBarChartForMonth(Map<int, List<Entry>> entriesByWeek) {
    
    const double font_size = 10.0;
    final JobSettings jobSettings = JobSettings();
    // Create a map of days of the month and total minutes worked on each day
    Map<int, int> daysOfMonth = {};

    for (var entries in entriesByWeek.values) {
      for (var entry in entries) {
        int day = entry.date.day;
        int minutesWorked = entry.endTime.difference(entry.startTime).inMinutes;
        if (daysOfMonth.containsKey(day)) {
          daysOfMonth[day] = daysOfMonth[day]! + minutesWorked;
        } else {
          daysOfMonth[day] = minutesWorked;
        }
      }
    }

    int daysInMonth = daysOfMonth.keys.isNotEmpty ? daysOfMonth.keys.reduce((a, b) => a > b ? a : b) : 31;
    const double chartHeight = 200.0 + font_size + 1;
    final int maxWorkMinutes = (jobSettings.work_duration_max.hour * 60) + jobSettings.work_duration_max.minute;
    final double section_height = chartHeight / jobSettings.work_duration_max.hour;

    return SizedBox(
      height: chartHeight,
      width: MediaQuery.of(context).size.width - 10,
      child: Stack(
        children: [
          // Draw horizontal lines for every hour
          for (int i = 1; i <= jobSettings.work_duration_max.hour; i++) 
            Positioned(
              top: chartHeight - (i * section_height),
              left: 0,
              right: 0,
              child: Text(
                '${i}h',
                style: const TextStyle(color: Colors.white70, fontSize: font_size),
              ),
            ),

          for (int i = 1; i <= jobSettings.work_duration_max.hour; i++) 
            Positioned(
              top: chartHeight - (i * section_height),
              left: 15,
              right: 15,
              child: const Divider(
                color: Colors.white30,
                thickness: 1.0,
              ),
            ),

          Positioned(
            top: 0,
            bottom: 0,
            left: 15,
            right: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(daysInMonth, (index) {
                int day = index + 1;
                int minutesWorked = daysOfMonth[day] ?? 0;
                double barHeight = min(((minutesWorked / maxWorkMinutes) * chartHeight), chartHeight - (font_size + 1));

                return Container(
                  width: (MediaQuery.of(context).size.width - 65) / (daysInMonth),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        day.toString(),
                        style: const TextStyle(color: Colors.white70, fontSize: (font_size-2)),
                      ),
                      SizedBox(
                        height: barHeight,
                        width: 10.0,
                        child: Container(
                          color: minutesWorked > 0 ? Colors.blue : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          
        ],
      ),
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

  void update_all_entries() {
    setState(() {
      for (var i = 0; i < entries.length; i++)
        entries[i].calculateAmount();
      
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
