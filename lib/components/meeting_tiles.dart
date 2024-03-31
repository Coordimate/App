import 'package:coordimate/components/meeting_action_button.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';

class MeetingTile extends StatelessWidget {
  final String title;
  final String date;
  final String group;
  final bool isArchived;

  const MeetingTile({
    super.key,
    required this.title,
    required this.date,
    required this.group,
    required this.isArchived,
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
                title,
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
              date,
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
                  group,
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
    required super.title,
    required super.date,
    required super.group,
  }) : super(
    isArchived: false, // Set isArchived to true
  );

  void _onPressed() {
    // Handle the tick button press
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
                  title,
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
                      date,
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
                          group,
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
                    onPressed: _onPressed,
                    color: lightBlue,
                    iconPath: 'lib/images/tick.png'
                ),
                const SizedBox(height: 10),
                ActionButton(
                    onPressed: _onPressed,
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
    required super.title,
    required super.date,
    required super.group,
  }) : super(
    isArchived: false, // Set isArchived to false
  );
}

class ArchivedMeetingTile extends MeetingTile {
  const ArchivedMeetingTile({
    super.key,
    required super.title,
    required super.date,
    required super.group,
  }) : super(
    isArchived: true, // Set isArchived to true
  );
}