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
    await AppState.meetingController.fetchArchivedMeetings()
        .then((newMeetings) => setState(() {
          meetings = newMeetings;
        }));
    widget.fetchMeetings();
  }

  @override
  Widget build(BuildContext context) {
    List<MeetingTileModel> declinedUpcomingMeetings = meetings
        .where((meeting) => meeting.status == MeetingStatus.declined
          && !meeting.isInPast() && !meeting.isFinished)
        .toList();
    List<MeetingTileModel> otherMeetings = meetings
        .where((meeting) => !(meeting.status == MeetingStatus.declined
        && !meeting.isInPast() && !meeting.isFinished))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Archive', needButton: false),
      body: ListView(
        children: [
          if (declinedUpcomingMeetings.isNotEmpty)
            const CustomDivider(text: 'Declined Upcoming Meetings'),
          if (declinedUpcomingMeetings.isNotEmpty)
            for (var meeting in declinedUpcomingMeetings)
              Padding(padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                child: ArchivedMeetingTile(
                  meeting: meeting,
                  fetchMeetings: fetchMeetings,
                ),
              ),
          if (otherMeetings.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: CustomDivider(text: 'Passed Meetings'),
            ),
          if (otherMeetings.isNotEmpty)
            for (var meeting in otherMeetings)
              MeetingTileWithPadding(
                  meeting: meeting,
                  fetchMeetings: fetchMeetings,
                  isAccepted: meeting.status == MeetingStatus.accepted
              ),
        ],
      ),
    );
  }
}

class MeetingTileWithPadding extends StatelessWidget {
  final MeetingTileModel meeting;
  final Future<void> Function() fetchMeetings;
  final bool isAccepted;

  const MeetingTileWithPadding({
    super.key,
    required this.meeting,
    required this.fetchMeetings,
    required this.isAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: isAccepted
          ? AcceptedMeetingTile(
        meeting: meeting,
        fetchMeetings: fetchMeetings,
      )
          : ArchivedMeetingTile(
        meeting: meeting,
        fetchMeetings: fetchMeetings,
      ),
    );
  }
}
