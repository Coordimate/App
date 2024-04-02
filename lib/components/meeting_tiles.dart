import 'package:coordimate/components/meeting_action_button.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/api_client.dart';
import 'dart:convert';

class MeetingTile extends StatelessWidget {
  final bool isArchived;
  final Meeting meeting;

  const MeetingTile({
    super.key,
    required this.isArchived,
    required this.meeting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isArchived ? Colors.grey : darkBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                meeting.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meeting.getFormattedDate(),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  meeting.group,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // Navigate to the meeting details page
        },
      ),
    );
  }
}

class NewMeetingTile extends MeetingTile {

  const NewMeetingTile({
    super.key,
    required super.meeting,
  }) : super(
    isArchived: false,
  );

  // Future<void> _acceptMeeting() async {
  //   final response = await client.patch(
  //     Uri.parse("$apiUrl/invites/$id/"),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: json.encode(<String, dynamic>{
  //       'status': 'accepted',
  //     }),
  //   );
  // }

  void _onAccept() {
    // Handle the accept button press
  }

  void _onDecline() {
    // Handle the decline button press
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: mediumBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
              child: ListTile(
                title: Text(
                  meeting.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.getFormattedDate(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white70),
                        const SizedBox(width: 8),
                        Text(
                          meeting.group,
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white70
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActionButton(
                    onPressed: _onAccept,
                    color: lightBlue,
                    iconPath: 'lib/images/tick.png'
                ),
                const SizedBox(height: 10),
                ActionButton(
                    onPressed: _onDecline,
                    color: orange,
                    iconPath: 'lib/images/cross.png'
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AcceptedMeetingTile extends MeetingTile {
  const AcceptedMeetingTile({
    super.key,
    required super.meeting
  }) : super(
    isArchived: false, // Set isArchived to false
  );
}

class ArchivedMeetingTile extends MeetingTile {
  const ArchivedMeetingTile({
    super.key,
    required super.meeting
  }) : super(
    isArchived: true, // Set isArchived to true
  );
}