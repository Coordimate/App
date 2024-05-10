import 'package:coordimate/components/meeting_action_button.dart';
import 'package:coordimate/pages/meeting_info_page.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';

class MeetingTile extends StatelessWidget {
  final bool isArchived;
  final Meeting meeting;
  final VoidCallback onAccepted;
  final VoidCallback onDeclined;

  const MeetingTile({
    super.key,
    required this.isArchived,
    required this.meeting,
    required this.onAccepted,
    required this.onDeclined,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetingDetailsPage(meeting: meeting),
            ),
          );
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
    required super.onAccepted,
    required super.onDeclined,
  }) : super(
    isArchived: false,
  );

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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MeetingDetailsPage(meeting: meeting),
                    ),
                  );
                  // Navigate to the meeting details page
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActionButton(
                    onPressed: onAccepted,
                    color: lightBlue,
                    iconPath: 'lib/images/tick.png'
                ),
                const SizedBox(height: 10),
                ActionButton(
                    onPressed: onDeclined,
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
    onAccepted: defaultOnPressed, // Set onAccepted to an empty function
    onDeclined: defaultOnPressed, // Set onDeclined to an empty function
  );
  static void defaultOnPressed() {}
}

class ArchivedMeetingTile extends MeetingTile {
  const ArchivedMeetingTile({
    super.key,
    required super.meeting
  }) : super(
    isArchived: true, // Set isArchived to true
    onAccepted: defaultOnPressed, // Set onAccepted to an empty function
    onDeclined: defaultOnPressed, // Set onDeclined to an empty function
  );
  static void defaultOnPressed() {}
}