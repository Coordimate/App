import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/delete_button.dart';
import 'package:coordimate/components/meeting_action_button.dart';
import 'package:coordimate/components/pop_up_dialog.dart';
import 'package:coordimate/components/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/components/agenda.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:coordimate/pages/meeting_summary_page.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/avatar.dart';

class MeetingDetailsPage extends StatefulWidget {
  final MeetingDetails meeting;

  const MeetingDetailsPage({super.key, required this.meeting});

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  late DateTime dateTime = widget.meeting.dateTime;
  late final textController =
      TextEditingController(text: widget.meeting.meetingLink ?? '');

  Future<void> _answerInvitation(bool accept) async {
    if (widget.meeting.isInPast()) {
      CustomSnackBar.show(context, "Meeting is in the past");
      return;
    }
    if (widget.meeting.isFinished) {
      CustomSnackBar.show(context, "Meeting is already finished");
      return;
    }
    var accId = await AppState.authController.getAccountId();
    await AppState.meetingController
        .answerInvitation(accept, widget.meeting.id)
        .then((status) {
      var meetingStatus = (status == MeetingStatus.accepted)
          ? "Meeting accepted"
          : "Meeting declined";
      setState(() {
        widget.meeting.status = status;
        widget.meeting.participants
            .firstWhere((element) => element.id == accId)
            .status = status.name;
        CustomSnackBar.show(context, meetingStatus);
      });
    });
  }

  Future<void> _finishMeeting() async {
    await AppState.meetingController
        .finishMeeting(widget.meeting.id)
        .then((isFinished) => setState(() {
      isFinished
          ? CustomSnackBar.show(context, "Meeting is finished")
          : CustomSnackBar.show(context, "Failed to finish meeting");
      isFinished && (widget.meeting.isFinished = isFinished);
    }));
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
            ConfirmationButtons(onYes: () async {
              await _answerInvitation(accept);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }, onNo: () {
              Navigator.of(context).pop();
            }),
          ],
        );
      },
    );
  }

  Future<void> _showMeetingOfflinePicker() async {
    var link = await AppState.meetingController.suggestMeetingLocation(widget.meeting.id);
    if (!await launchUrl(Uri.parse(link))) {
      throw Exception('Could not launch offline meeting location picker');
    }
  }

  void showDeleteMeetingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopUpDialog(
          question: "Do you want to delete meeting \n\"${widget.meeting.title}\"?",
          onYes: () async {
            await AppState.meetingController.deleteMeeting(
                widget.meeting.id, widget.meeting.googleEventId);
          },
          onNo: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showSummaryPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SummaryPage(
          id: widget.meeting.id,
          summary: widget.meeting.summary,
        ),
      ),
    ).then((_) async => await AppState.meetingController
        .fetchMeetingSummary(widget.meeting.id)
        .then((summary) => setState(() { widget.meeting.summary = summary; }))
    );
  }

  void _showMeetingAgendaPage() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MeetingAgenda(
        key: UniqueKey(), meetingId: widget.meeting.id)
    ));
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
                    GestureDetector(
                      onTap: () async {
                        _selectDate();
                      },
                      child: buildInfoRow(Icons.calendar_today, "Date",
                          widget.meeting.getFormattedDate(dateTime)),
                    ),
                    GestureDetector(
                      onTap: () async {
                        _selectTime();
                      },
                      child: buildInfoRow(Icons.access_time, "Time",
                          widget.meeting.getFormattedTime(dateTime)),
                    ),
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

              if (widget.meeting.status == MeetingStatus.accepted && !widget.meeting.isFinished && !widget.meeting.isInPast())
              MeetingActionButton(
                  text: "Meet Offline",
                  onPressed: _showMeetingOfflinePicker,
                  backgroundColor: mediumBlue
              ),

              if (widget.meeting.status == MeetingStatus.accepted)
                MeetingActionButton(
                    text: "Meeting Agenda",
                    onPressed: _showMeetingAgendaPage,
                    backgroundColor: darkBlue
                ),

              if (widget.meeting.status == MeetingStatus.accepted)
                MeetingActionButton(
                    text: widget.meeting.isFinished
                        ? "Summary"
                        : "Finish Meeting",
                    onPressed: () async {
                      if (widget.meeting.isFinished) {
                        _showSummaryPage();
                      } else {
                        await _finishMeeting();
                      }
                    },
                    backgroundColor: mediumBlue
                ),

              if (widget.meeting.status == MeetingStatus.needsAcceptance)
                Row(
                  children: <Widget>[
                    answerButton(
                        "Accept", lightBlue, () => _answerInvitation(true)),
                    const SizedBox(width: 16),
                    answerButton(
                        "Decline", orange, () => _answerInvitation(false)),
                  ],
                ),

              if (widget.meeting.status == MeetingStatus.declined && !widget.meeting.isInPast())
                MeetingActionButton(
                    text: "Attend Meeting",
                    onPressed: () async {
                      await showPopUpDialog(context, true);
                    },
                    backgroundColor: Colors.grey
                ),

              if (widget.meeting.status == MeetingStatus.declined && widget.meeting.isInPast())
                MeetingActionButton(
                    text: "Invitation Declined",
                    onPressed: () {},
                    backgroundColor: Colors.white
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
                    leading: Avatar(size: 30, userId: participant.id),
                    title: Text(participant.username,
                        style: const TextStyle(color: darkBlue)),
                    subtitle: Text(participant.status,
                        style: TextStyle(color: alphaDarkBlue)),
                  );
                }).toList(),
              ),
              Center(
                child: Container(
                  color: white,
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DeleteButton(
                    itemToDelete: 'Meeting',
                    showDeleteDialog: showDeleteMeetingDialog,
                    color: orange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.meeting.dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
                primary: lightBlue,
                onPrimary: darkBlue,
                onSurface: darkBlue,
                surfaceTint: Colors.white),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: darkBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      var selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        widget.meeting.dateTime.hour,
        widget.meeting.dateTime.minute,
      );
      await AppState.meetingController.updateMeetingTime(
          widget.meeting.id,
          selectedDateTime.toUtc().toIso8601String(),
          widget.meeting.duration,
          widget.meeting.googleEventId);
      setState(() {
        dateTime = selectedDateTime;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.meeting.dateTime),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
                primary: lightBlue,
                onPrimary: darkBlue,
                onSurface: darkBlue,
                surfaceTint: Colors.white),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: darkBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      var selectedDateTime = DateTime(
        widget.meeting.dateTime.year,
        widget.meeting.dateTime.month,
        widget.meeting.dateTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      await AppState.meetingController.updateMeetingTime(
          widget.meeting.id,
          selectedDateTime.toUtc().toIso8601String(),
          widget.meeting.duration,
          widget.meeting.googleEventId);
      setState(() {
        dateTime = selectedDateTime;
      });
    }
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
