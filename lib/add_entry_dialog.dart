// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEntryDialog extends StatefulWidget {
  final Function(DateTime, TimeOfDay, TimeOfDay) onEntryAdded;

  const AddEntryDialog({Key? key, required this.onEntryAdded}) : super(key: key);

  @override
  _AddEntryDialogState createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<AddEntryDialog> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Entry"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Date:", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Text(DateFormat.yMd().format(selectedDate)),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Start Time:", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showDialog<TimeOfDay>(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomTimePicker(initialTime: selectedStartTime);
                  },
                );
                if (picked != null && picked != selectedStartTime) {
                  setState(() {
                    selectedStartTime = picked;
                  });
                }
              },
              child: Text(DateFormat.Hm().format( DateTime( 0, 0, 0, selectedStartTime.hour, selectedStartTime.minute ))),
            ),
          ),
          const SizedBox(height: 16),
          const Text("End Time:", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showDialog<TimeOfDay>(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomTimePicker(initialTime: selectedEndTime);
                  },
                );
                if (picked != null && picked != selectedEndTime) {
                  setState(() {
                    selectedEndTime = picked;
                  });
                }
              },
              child: Text(DateFormat.Hm().format( DateTime( 0, 0, 0, selectedEndTime.hour, selectedEndTime.minute ))),
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
            Navigator.of(context).pop();
            widget.onEntryAdded(selectedDate, selectedStartTime, selectedEndTime);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}
