// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

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
      // Minute wraps from 59 to 0, increment hour
      setState(() {
        hour = (hour + 1) % 24;
      });
    } else if (value == 59 && minute == 0) {
      // Minute wraps from 0 to 59, decrement hour
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
              "Pick Your Time! ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, "0")}",
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
                    selectedTextStyle:
                        const TextStyle(color: Colors.white, fontSize: 30),
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
                    selectedTextStyle:
                        const TextStyle(color: Colors.white, fontSize: 30),
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
