import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'entry.dart';
import 'util.dart';

class EditEntryDialog extends StatefulWidget {
  final Entry entry;
  final Function(Entry) onSave;

  const EditEntryDialog({required this.entry, required this.onSave});

  @override
  _EditEntryDialogState createState() => _EditEntryDialogState();
}

class _EditEntryDialogState extends State<EditEntryDialog> {
  late Entry editedEntry;
  late DateTime selectedStartTime;
  late DateTime selectedEndTime;

  @override
  void initState() {
    super.initState();
    editedEntry = Entry.clone(widget.entry);
    selectedStartTime = editedEntry.startTime;
    selectedEndTime = editedEntry.endTime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Entry"),
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
          const Text("Start Time:", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showDialog<TimeOfDay>(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomTimePicker(
                      initialTime: TimeOfDay(
                        hour: selectedStartTime.hour,
                        minute: selectedStartTime.minute,
                      ),
                    );
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
          const Text("End Time:", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showDialog<TimeOfDay>(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomTimePicker(
                      initialTime: TimeOfDay(
                        hour: selectedEndTime.hour,
                        minute: selectedEndTime.minute,
                      ),
                    );
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
            editedEntry.startTime = selectedStartTime;
            editedEntry.endTime = selectedEndTime;
            editedEntry.calculateAmount();
            widget.onSave(editedEntry);
            Navigator.of(context).pop();
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
