
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:intl/intl.dart';
import 'util.dart';

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




class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;

  CustomTimePicker({required this.initialTime});

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late int hour;
  late int minute;

  @override
  void initState() {
    super.initState();
    hour = widget.initialTime.hour;
    minute = widget.initialTime.minute;
  }

  void _updateMinute(int value) {
    if (value == 0 && minute == 59) {
      setState(() {
        hour = (hour + 1) % 24;
      });
    } else if (value == 59 && minute == 0) {
      setState(() {
        hour = (hour - 1 + 24) % 24;
      });
    }
    setState(() {
      minute = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Pick Your Time! ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NumberPicker(
                    minValue: 0,
                    maxValue: 23,
                    value: hour,
                    zeroPad: true,
                    infiniteLoop: true,
                    itemWidth: 80,
                    itemHeight: 60,
                    onChanged: (value) {
                      setState(() {
                        hour = value;
                      });
                    },
                    textStyle: const TextStyle(color: Colors.grey, fontSize: 20),
                    selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 30),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.white),
                        bottom: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  NumberPicker(
                    minValue: 0,
                    maxValue: 59,
                    value: minute,
                    zeroPad: true,
                    infiniteLoop: true,
                    itemWidth: 80,
                    itemHeight: 60,
                    onChanged: _updateMinute,
                    textStyle: const TextStyle(color: Colors.grey, fontSize: 20),
                    selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 30),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.white),
                        bottom: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                TimeOfDay selectedTime = TimeOfDay(hour: hour, minute: minute);
                Navigator.of(context).pop(selectedTime);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}

class JobSettingsDialog extends StatefulWidget {
  @override
  _JobSettingsDialogState createState() => _JobSettingsDialogState();
}

class _JobSettingsDialogState extends State<JobSettingsDialog> {
  final JobSettings jobSettings = JobSettings();

  late TextEditingController _hourlyRateController;
  late TextEditingController _eveningHourlyRateController;
  late TextEditingController _nightHourlyRateController;

  @override
  void initState() {
    super.initState();
    _hourlyRateController = TextEditingController(text: jobSettings.hourlyRate.toString());
    _eveningHourlyRateController = TextEditingController(text: jobSettings.eveningHourlyRate.toString());
    _nightHourlyRateController = TextEditingController(text: jobSettings.nightHourlyRate.toString());
  }

  @override
  void dispose() {
    _hourlyRateController.dispose();
    _eveningHourlyRateController.dispose();
    _nightHourlyRateController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final DateTime now = DateTime.now();
    final DateTime timeOfDay = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.Hm().format(timeOfDay);
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime, ValueChanged<TimeOfDay> onTimeSelected) async {
    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return CustomTimePicker(initialTime: initialTime);
      },
    );

    if (picked != null) {
      setState(() {
        onTimeSelected(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Job Settings'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _hourlyRateController,
              decoration: const InputDecoration(labelText: 'Hourly Rate'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _eveningHourlyRateController,
              decoration: const InputDecoration(labelText: 'Evening Hourly Rate'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _nightHourlyRateController,
              decoration: const InputDecoration(labelText: 'Night Hourly Rate'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Evening Begin Time:", style: TextStyle(color: Colors.white)),
                ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? picked = await showDialog<TimeOfDay>(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomTimePicker(
                          initialTime: jobSettings.eveningBeginTime,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        jobSettings.eveningBeginTime = picked;
                      });
                    }
                  },
                  child: Text(_formatTime(jobSettings.eveningBeginTime)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Night Begin Time   ", style: TextStyle(color: Colors.white)),
                ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? picked = await showDialog<TimeOfDay>(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomTimePicker(
                          initialTime: jobSettings.nightBeginTime,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        jobSettings.nightBeginTime = picked;
                      });
                    }
                  },
                  child: Text(_formatTime(jobSettings.nightBeginTime)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Min Work Duration:", style: TextStyle(color: Colors.white)),
                ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? picked = await showDialog<TimeOfDay>(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomTimePicker(
                          initialTime: jobSettings.work_duration_min,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        jobSettings.work_duration_min = picked;
                      });
                    }
                  },
                  child: Text(_formatTime(jobSettings.work_duration_min)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Max Work Duration:", style: TextStyle(color: Colors.white)),
                ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? picked = await showDialog<TimeOfDay>(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomTimePicker(
                          initialTime: jobSettings.work_duration_max,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        jobSettings.work_duration_max = picked;
                      });
                    }
                  },
                  child: Text(_formatTime(jobSettings.work_duration_max)),
                ),
              ],
            ),

          ],
        ),
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
            jobSettings.hourlyRate = double.parse(_hourlyRateController.text);
            jobSettings.eveningHourlyRate = double.parse(_eveningHourlyRateController.text);
            jobSettings.nightHourlyRate = double.parse(_nightHourlyRateController.text);
            Navigator.of(context).pop();
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
