import 'package:coordimate/components/appbar.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/models/meeting.dart';

class MeetingDetailsPage extends StatefulWidget {
  final MeetingTileModel meeting;

  const MeetingDetailsPage({super.key, required this.meeting});

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Meeting Details',
        needButton: false
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Title: ${widget.meeting.title}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            Text(
              'Date: ${widget.meeting.dateTime}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              'Status: ${widget.meeting.status.name}',
              style: TextStyle(fontSize: 20),
            ),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}