import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/divider.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/meeting_tiles.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/keys.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:coordimate/api_client.dart';

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
  List<Meeting> meetings = [];

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

  Future<void> _createMeeting() async {
    final response = await client.post(
      Uri.parse("$apiUrl/meetings/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': _titleController.text,
        'start': _selectedDate.toIso8601String(),
        'description': _descriptionController.text,
        'group_id': '1',
        'needs_acceptance': true,
        'accepted': false,
      }),
    );
    if (response.statusCode == 201) {
      fetchMeetings();
    } else {
      throw Exception('Failed to create meeting');
    }
  }

  void clearControllers() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedDate = DateTime.now();
  }

  void _onCreateMeeting() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                      title: Text(DateFormat('EEE, MMMM d, HH:mm').format(_selectedDate.toLocal())),
                      trailing: const Icon(Icons.keyboard_arrow_down),
                      onTap: () async {
                        await _selectDate(context);
                        setState(() {});  // Rebuild the dialog to update the date
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
                    clearControllers();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Create'),
                  onPressed: () {
                    _createMeeting();
                    clearControllers();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchMeetings();
  }

  Future<void> fetchMeetings() async {
    final response = await client.get(Uri.parse("$apiUrl/meetings/"));
    if (response.statusCode == 200) {
      print(response.body);
      print(json.decode(response.body)['meetings'][0]);
      setState(() {
        meetings = (json.decode(response.body)['meetings'] as List)
            .map((data) => Meeting.fromJson(data))
            .toList();
        meetings.sort((a, b) => a.dateTime.difference(DateTime.now()).inMilliseconds - b.dateTime.difference(DateTime.now()).inMilliseconds);
      });
    } else {
      throw Exception('Failed to load meetings');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Meeting> declinedMeetings = meetings.where((meeting) => meeting.status == MeetingStatus.declined).toList();
    List<Meeting> newInvitations = meetings.where((meeting) => meeting.status == MeetingStatus.needsAcceptance).toList();
    List<Meeting> acceptedMeetings = meetings.where((meeting) => meeting.status == MeetingStatus.accepted).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Meetings", needCreateButton: true, onPressed: _onCreateMeeting),
      body: ListView(
        children: [
          if (declinedMeetings.isNotEmpty) ...[
            _buildMeetingList(declinedMeetings, "Declined Meetings"),
          ],
          if (newInvitations.isNotEmpty) ...[
            _buildMeetingList(newInvitations, "New Invitations"),
          ],
          if (acceptedMeetings.isNotEmpty) ...[
            _buildMeetingList(acceptedMeetings, "Accepted Meetings"),
          ],
        ],
      ),
    );
  }

  Widget _buildMeetingList(List<Meeting> meetings, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomDivider(text: title),
        const SizedBox(height: 16),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            // Build meeting tile based on meeting status
            if (meetings[index].status == MeetingStatus.needsAcceptance) {
              return NewMeetingTile(
                title: meetings[index].title,
                date: meetings[index].getFormattedDate(),
                group: meetings[index].group,
              );
            } else if (meetings[index].status == MeetingStatus.declined) {
              return ArchivedMeetingTile(
                title: meetings[index].title,
                date: meetings[index].getFormattedDate(),
                group: meetings[index].group,
              );
            } else {
              return AcceptedMeetingTile(
                title: meetings[index].title,
                date: meetings[index].getFormattedDate(),
                group: meetings[index].group,
              );
            }
          },
        ),
      ],
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

