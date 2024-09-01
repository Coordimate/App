import 'package:coordimate/widget_keys.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/models/meeting.dart';

class RandomCoffeeInvitationPage extends StatelessWidget {
  final MeetingDetails meeting;

  RandomCoffeeInvitationPage({super.key, required this.meeting});

  late final String partnerUsername = meeting.participants
      .where((p) => (p.id != AppState.authController.userId))
      .first
      .username;
  late final String month = intl.DateFormat("MMMM").format(meeting.dateTime);
  late final String day = intl.DateFormat("d").format(meeting.dateTime);
  late final String hour = intl.DateFormat("HH").format(meeting.dateTime);
  late final String minute = intl.DateFormat("mm").format(meeting.dateTime);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Time to grab some coffee!',
          style: TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          )),
      const SizedBox(height: 16),
      Text('With $partnerUsername',
          style: const TextStyle(
            color: darkBlue,
            fontSize: 18,
          )),
      const SizedBox(height: 16),
      Text(month,
          style: const TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          )),
      Text(day,
          style: const TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 60,
          )),
      Text("$hour:$minute",
          style: const TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          )),
      const SizedBox(height: 32),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        IconButton(
            key: randomCoffeeAcceptKey,
            onPressed: () async {
              await AppState.meetingController
                  .answerInvitation(true, meeting.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.thumb_up, color: Colors.green, size: 60)),
        IconButton(
            key: randomCoffeeDeclineKey,
            onPressed: () async {
              await AppState.meetingController
                  .answerInvitation(false, meeting.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.thumb_down, color: Colors.red, size: 60)),
      ])
    ])));
  }
}
