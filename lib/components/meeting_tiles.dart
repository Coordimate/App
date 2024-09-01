import 'package:coordimate/components/invitation_action_button.dart';
import 'package:coordimate/pages/meeting_info_page.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/widget_keys.dart';

class MeetingTile extends StatelessWidget {
  final bool isArchived;
  final MeetingTileModel meeting;
  final VoidCallback onAccepted;
  final VoidCallback onDeclined;
  final Function fetchMeetings;
  final Color? color; // Optional color field

  const MeetingTile({
    super.key,
    required this.isArchived,
    required this.meeting,
    required this.onAccepted,
    required this.onDeclined,
    required this.fetchMeetings,
    this.color, // Initialize color field
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color ??
            (isArchived
                ? Colors.grey
                : darkBlue), // Use custom color if provided
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
                const Icon(Icons.group, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    meeting.group.name,
                    style: const TextStyle(fontSize: 20, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          AppState.meetingController
              .fetchMeetingDetails(meeting.id)
              .then((meetingDetails) {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MeetingDetailsPage(meeting: meetingDetails),
                ),
              ).then((_) {
                fetchMeetings();
              });
            }
          });
        },
      ),
    );
  }
}

class NewMeetingTile extends MeetingTile {
  const NewMeetingTile({
    super.key,
    required super.meeting,
    required super.onAccepted,
    required super.onDeclined,
    required super.fetchMeetings,
    Color? color, // Optional color
  }) : super(
          isArchived: false,
          color: color, // Pass color to superclass
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color ?? mediumBlue, // Use custom color or default to mediumBlue
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
                      const Icon(Icons.group, color: Colors.white70),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          meeting.group.name,
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                AppState.meetingController
                    .fetchMeetingDetails(meeting.id)
                    .then((meetingDetails) {
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MeetingDetailsPage(meeting: meetingDetails),
                      ),
                    ).then((_) {
                      fetchMeetings();
                    });
                  }
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InvitationActionButton(
                  key: acceptButtonKey,
                  onPressed: onAccepted,
                  color: lightBlue,
                  iconPath: 'lib/images/tick.png'),
                const SizedBox(height: 10),
                InvitationActionButton(
                  key: declineButtonKey,
                  onPressed: onDeclined,
                  color: orange,
                  iconPath: 'lib/images/cross.png'),
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
    required super.meeting,
    required super.fetchMeetings,
    Color? color, // Optional color
  }) : super(
          isArchived: false,
          onAccepted: defaultOnPressed,
          onDeclined: defaultOnPressed,
          color: color, // Pass color to superclass
        );

  static void defaultOnPressed() {}
}

class ArchivedMeetingTile extends MeetingTile {
  const ArchivedMeetingTile({
    super.key,
    required super.meeting,
    required super.fetchMeetings,
    Color? color, // Optional color
  }) : super(
          isArchived: true,
          onAccepted: defaultOnPressed,
          onDeclined: defaultOnPressed,
          color: color, // Pass color to superclass
        );

  static void defaultOnPressed() {}
}
