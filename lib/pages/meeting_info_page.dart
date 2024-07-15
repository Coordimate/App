import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/pop_up_dialog.dart';
import 'package:coordimate/components/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/components/agenda.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:coordimate/pages/meeting_summary_page.dart';
import 'package:coordimate/app_state.dart';

class MeetingDetailsPage extends StatefulWidget {
  final MeetingDetails meeting;

  const MeetingDetailsPage({super.key, required this.meeting});

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  final textController = TextEditingController();

  Future<void> _answerInvitation(bool accept) async {
    if (widget.meeting.isInPast()) {
      CustomSnackBar.show(context, "Meeting is in the past");
      return;
    }
    if (widget.meeting.isFinished) {
      CustomSnackBar.show(context, "Meeting is already finished");
      return;
    }
    await AppState.meetingController.answerInvitation(accept, widget.meeting.id).then((status) {
      status == MeetingStatus.accepted
          ? CustomSnackBar.show(context, "Meeting accepted")
          : CustomSnackBar.show(context, "Meeting declined");
      setState(() {
        widget.meeting.status = status;
      });
    });
  }

  Future<void> showPopUpDialog(BuildContext context, bool accept) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Align(
              alignment: Alignment.center,
              child: Text(
                  accept
                      ? "Do you want to attend the meeting?"
                      : "Do you want to decline the invitation?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: darkBlue, fontWeight: FontWeight.bold))),
          actions: <Widget>[
            ConfirmationButtons(
                onYes: () async {
                  await _answerInvitation(accept);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                onNo: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: '',
        needButton: true,
        buttonIcon: Icons.settings,
        onPressed: widget.meeting.isInPast()
            ? null
            : () {
                showPopUpDialog(
                    context, widget.meeting.status != MeetingStatus.accepted);
              },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.meeting.title,
                style: const TextStyle(
                    fontSize: 30, fontWeight: FontWeight.bold, color: darkBlue),
              ),
              if (widget.meeting.description.isNotEmpty)
                const SizedBox(height: 16),
              if (widget.meeting.description.isNotEmpty)
                Text(
                  widget.meeting.description,
                  style: const TextStyle(fontSize: 20, color: darkBlue),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: darkBlue, width: 5),
                ),
                child: Column(
                  children: <Widget>[
                    buildInfoRow(Icons.calendar_today, "Date",
                        widget.meeting.getFormattedDate()),
                    buildInfoRow(Icons.access_time, "Time",
                        widget.meeting.getFormattedTime()),
                    buildInfoRow(
                        Icons.group, "Group", widget.meeting.groupName),
                    buildInfoRow(
                        Icons.person, "Host", widget.meeting.admin.username)
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (widget.meeting.status == MeetingStatus.accepted)
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: alphaDarkBlue,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: darkBlue,
                        ),
                      ),
                      hintText: 'Insert link or address here',
                      hintStyle: TextStyle(color: alphaDarkBlue),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: textController.text));
                              CustomSnackBar.show(
                                  context, "Copied to clipboard",
                                  duration: const Duration(seconds: 1));
                            },
                            icon: const Icon(Icons.copy, color: darkBlue),
                            color: darkBlue,
                          ),
                          IconButton(
                            onPressed: () {
                              Share.share(textController.text);
                            },
                            icon: const Icon(Icons.share, color: darkBlue),
                            color: darkBlue,
                          ),
                        ],
                      )),
                ),
              const SizedBox(height: 10),
              if (widget.meeting.status == MeetingStatus.accepted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MeetingAgenda(
                              key: UniqueKey(), meetingId: widget.meeting.id)));
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(darkBlue),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: const Text("Meeting Agenda",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              if (widget.meeting.status == MeetingStatus.accepted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (widget.meeting.isFinished) {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => SummaryPage(
                                  id: widget.meeting.id,
                                  summary: widget.meeting.summary,
                                ),
                              ),
                            )
                        .then((_) async => await AppState.meetingController
                            .fetchMeetingSummary(widget.meeting.id)
                            .then((summary) => setState(() {
                              widget.meeting.summary = summary;
                            })));
                      } else {
                        await AppState.meetingController.finishMeeting(widget.meeting.id).then((isFinished) => setState(() {
                          isFinished
                              ? CustomSnackBar.show(context, "Meeting is finished")
                              : CustomSnackBar.show(context, "Failed to finish meeting");
                          isFinished && (widget.meeting.isFinished = isFinished);
                        }));
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(mediumBlue),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: Text(
                        widget.meeting.isFinished
                            ? "Summary"
                            : "Finish Meeting",
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              if (widget.meeting.status == MeetingStatus.needsAcceptance)
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    answerButton(
                        "Accept", lightBlue, () => _answerInvitation(true)),
                    const SizedBox(width: 16),
                    answerButton(
                        "Decline", orange, () => _answerInvitation(false)),
                  ],
                ),
              if (widget.meeting.status == MeetingStatus.declined)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.meeting.isInPast()
                        ? null
                        : () async {
                            await showPopUpDialog(context, true);
                          },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          widget.meeting.isInPast()
                              ? Colors.grey[300]
                              : Colors.grey),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: Text("Invitation Declined",
                        style: TextStyle(
                            fontSize: 20,
                            color: widget.meeting.isInPast()
                                ? alphaDarkBlue
                                : darkBlue,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                "Participants",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: darkBlue),
              ),
              Column(
                children: widget.meeting.participants.map((participant) {
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(participant.username,
                        style: const TextStyle(color: darkBlue)),
                    subtitle: Text(participant.status,
                        style: TextStyle(color: alphaDarkBlue)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: <Widget>[
        Icon(icon),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 20, color: darkBlue)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 20, color: darkBlue, fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget answerButton(
      String text, Color color, Future<void> Function() onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(color),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        child: Text(text,
            style: const TextStyle(
                color: darkBlue, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
    );
  }
}
