import 'package:coordimate/components/appbar.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/components/meeting_tiles.dart';
import 'package:coordimate/api_client.dart';
import 'package:coordimate/keys.dart';
import 'dart:convert';

class MeetingsArchivePage extends StatefulWidget {
  final List<MeetingTileModel> meetings;
  final Function fetchMeetings;

  const MeetingsArchivePage({
    super.key,
    required this.meetings,
    required this.fetchMeetings,
  });

  @override
  State<MeetingsArchivePage> createState() => _MeetingsArchivePageState();
}

class _MeetingsArchivePageState extends State<MeetingsArchivePage> {
  List<MeetingTileModel> meetings = [];

  @override
  void initState() {
    meetings = widget.meetings;
    super.initState();
  }

  Future<void> _fetchDeclinedMeetings() async {
    final response = await client.get(Uri.parse("$apiUrl/meetings/"));
    if (response.statusCode == 200) {
      if (!mounted) {return;}
      setState(() {
        meetings = (json.decode(response.body)['meetings'] as List)
            .map((data) => MeetingTileModel.fromJson(data))
            .where((meeting) => meeting.status == MeetingStatus.declined)
            .toList();
        meetings.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      });
    } else {
      throw Exception('Failed to load declined meetings');
    }
  }

  void _removeMeetingFromList(String id) {
    setState(() {
      meetings.removeWhere((element) => element.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Archive',
          needButton: false
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView.builder(
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            return ArchivedMeetingTile(
              meeting: meetings[index],
              fetchMeetings: () {
                _fetchDeclinedMeetings();
                widget.fetchMeetings();
                },
            );
          },
        ),
      ),
    );
  }
}