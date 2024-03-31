import 'package:coordimate/components/appbar.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/meeting_tiles.dart';

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({
    super.key,
  });

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022, 1),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _onCreateMeeting() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Meeting'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter the title of the meeting',
                  ),
                ),
                ListTile(
                  title: Text("Date: ${_selectedDate.toLocal()}"),
                  trailing: const Icon(Icons.keyboard_arrow_down),
                  onTap: () {
                    _selectDate(context);
                  },
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter the description of the meeting',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                // Handle the meeting creation
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Meetings", needCreateButton: true, onPressed: _onCreateMeeting),
      body: _buildListView(),
    );
  }

  ListView _buildListView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        ...List.generate(3, (index) => NewMeetingTile(
            title: "New Meeting $index blablabla",
            date: "Wed, September 20, 12:30",
            group: "Doggies Group"
        )),
        ...List.generate(2, (index) => AcceptedMeetingTile(
            title: "Accepted Meeting $index blablablabla",
            date: "Wed, September 20, 12:30",
            group: "Doggies Group"
        )),
        ...List.generate(3, (index) => ArchivedMeetingTile(
            title: "Archived Meeting $index blablablabla",
            date: "Wed, September 20, 12:30",
            group: "Doggies Group"
        )),
      ],
    );
  }
}

