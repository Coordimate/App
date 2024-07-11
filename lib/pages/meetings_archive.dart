import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/divider.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/components/meeting_tiles.dart';

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

  Future<void> fetchMeetings() async {
    await AppState.meetingController.fetchDeclinedMeetings()
        .then((newMeetings) => setState(() {
          meetings = newMeetings;
        }));
    widget.fetchMeetings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Archive', needButton: false),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView.builder(
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            if (index == meetings.indexWhere((meeting) => meeting.isInPast())) {
              return Column(
                children: [
                  const CustomDivider(
                    text: 'Passed Meetings',
                  ),
                  const SizedBox(height: 16.0),
                  ArchivedMeetingTile(
                    meeting: meetings[index],
                    fetchMeetings: () async { fetchMeetings(); }
                  ),
                ],
              );
            } else if (meetings[index].status == MeetingStatus.declined) {
              return ArchivedMeetingTile(
                meeting: meetings[index],
                fetchMeetings: () async { fetchMeetings(); },
              );
            } else {
              return AcceptedMeetingTile(
                meeting: meetings[index],
                fetchMeetings: () async { fetchMeetings(); }
              );
            }
          },
        ),
      ),
    );
  }
}
