import 'package:flutter/material.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/divider.dart';
import 'package:coordimate/components/meeting_tiles.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/keys.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:coordimate/api_client.dart';

class GroupDetailsPage extends StatefulWidget {
  final Group group;

  GroupDetailsPage({required this.group});

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  List<MeetingTileModel> meetings = [];

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
  }

  Future<void> _fetchMeetings() async {
    final response = await client.get(Uri.parse("$apiUrl/meetings/"));
    if (response.statusCode == 200) {
      if (!mounted) {
        return;
      }
      setState(() {
        meetings = (json.decode(response.body)['meetings'] as List)
            .map((data) => MeetingTileModel.fromJson(data))
            .toList();
      });
    } else {
      throw Exception('Failed to load meetings');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<MeetingTileModel> acceptedMeetings = meetings
        .where((meeting) => meeting.status == MeetingStatus.accepted)
        .toList();
    List<MeetingTileModel> acceptedFutureMeetings = acceptedMeetings
        .where((meeting) => meeting.dateTime.isAfter(DateTime.now()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable the default back button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Navigate back
              },
            ),
            TextButton(
              onPressed: () {
                // Functionality to be added later
              },
              child: Text('Edit'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: CircleAvatar(
                  radius: 52.0, // Adjust the size as needed
                  backgroundColor: Colors.grey[300], // Placeholder color
                  child: Icon(
                    Icons.group,
                    size: 40.0, // Adjust the size as needed
                    color: Colors.white,
                  ),
                ),
              ),
              Center(
                child: Text(
                  widget.group.name,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Members',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 16.0), // Added spacing
              if (acceptedFutureMeetings.isNotEmpty)
                _buildMeetingList(acceptedFutureMeetings, "Upcoming Meetings"),
              SizedBox(height: 16.0), // Added spacing
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Group Actions',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0), // Added spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            // Archive button functionality
                          },
                          child: Text('Archive'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Invite button functionality
                          },
                          child: Text('Invite'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Create button functionality
                          },
                          child: Text('Create'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0), // Added spacing
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: TextEditingController(
                            text: widget.group.description),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Description',
                        ),
                        maxLines: 3,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingList(List<MeetingTileModel> meetings, String title) {
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
            return AcceptedMeetingTile(
              meeting: meetings[index],
              fetchMeetings: _fetchMeetings,
            );
          },
        ),
      ],
    );
  }
}
