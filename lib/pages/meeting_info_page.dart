import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/delete_button.dart';
import 'package:coordimate/components/meeting_action_button.dart';
import 'package:coordimate/components/pop_up_dialog.dart';
import 'package:coordimate/components/snack_bar.dart';
import 'package:coordimate/widget_keys.dart';
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
  late var isAdmin = false;

  Future<void> _answerInvitation(bool accept) async {
    if (widget.meeting.isInPast()) {
      CustomSnackBar.show(context, "Meeting is in the past");
      return;
    }
    if (widget.meeting.isFinished) {
      CustomSnackBar.show(context, "Meeting is already finished");
      return;
    }
    await AppState.meetingController
        .answerInvitation(accept, widget.meeting.id)
        .then((status) {
      var meetingStatus = (status == MeetingStatus.accepted)
          ? "Meeting accepted"
          : "Meeting declined";
      setState(() {
        widget.meeting.status = status;
        widget.meeting.participants
            .firstWhere((element) => element.id == AppState.authController.userId)
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

  void _showFinishMeetingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopUpDialog(
          question: "Do you want to finish the meeting?",
          onYes: () async {
            await _finishMeeting();
            if (context.mounted) { Navigator.of(context).pop(); }
          },
          onNo: () {
            if (context.mounted) { Navigator.of(context).pop(); }
          },
        );
      },
    );
  }

  Future<void> showPopUpDialog(BuildContext context, bool accept) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          key: alertDialogKey,
          backgroundColor: Colors.white,
          title: Align(
              alignment: Alignment.center,
              child: Text(
                  accept
                      ? "Do you want to attend the meeting?"
                      : "Do you want to withdraw from meeting?",
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
              }
            ),
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
            await AppState.meetingController
                .deleteMeeting(widget.meeting.id, widget.meeting.googleEventId);
            if (context.mounted) Navigator.of(context).pop();
            if (context.mounted) Navigator.of(context).pop();
            if (context.mounted) CustomSnackBar.show(context, "Meeting is deleted");
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
  final isAdmin = widget.meeting.admin.id == AppState.authController.userId;
  final showWithdrawOrDeleteButton = (!widget.meeting.isInPast() && !widget.meeting.isFinished && !isAdmin && widget.meeting.status == MeetingStatus.accepted) || isAdmin;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: '',
        needButton: false
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
                          widget.meeting.getFormattedDate(dateTime)),
                    buildInfoRow(Icons.access_time, "Time",
                          widget.meeting.getFormattedTime(dateTime)),
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
                  key: linkPlaceholderFieldKey,
                  onSubmitted: (String s) async {
                    await AppState.meetingController.updateMeetingLink(
                        widget.meeting.id, s);
                  },
                  onTapOutside: (_) async {
                    await AppState.meetingController.updateMeetingLink(
                        widget.meeting.id, textController.text);
                  },
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
                            key: copyButtonKey,
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
                            key: shareButtonKey,
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
                key: meetOfflineButtonKey,
                text: "Meet Offline",
                onPressed: _showMeetingOfflinePicker,
                backgroundColor: mediumBlue
              ),

              if (widget.meeting.status == MeetingStatus.accepted)
                MeetingActionButton(
                  key: meetingAgendaButtonKey,
                  text: "Meeting Agenda",
                  onPressed: _showMeetingAgendaPage,
                  backgroundColor: darkBlue
                ),

              if (widget.meeting.status == MeetingStatus.accepted)
                MeetingActionButton(
                  key: widget.meeting.isFinished
                      ? summaryButtonKey
                      : finishMeetingButtonKey,
                  text: widget.meeting.isFinished
                      ? "Summary"
                      : "Finish Meeting",
                  onPressed: () async {
                    if (widget.meeting.isFinished) {
                      _showSummaryPage();
                    } else {
                      _showFinishMeetingDialog();
                    }
                  },
                  backgroundColor: mediumBlue
                ),

              if (widget.meeting.status == MeetingStatus.needsAcceptance)
                Row(
                  key: answerButtonsKey,
                  children: <Widget>[
                    answerButton(
                        "Accept", lightBlue, () => _answerInvitation(true)),
                    const SizedBox(width: 16),
                    answerButton(
                        "Decline", orange, () => _answerInvitation(false)),
                  ],
                ),

              if (widget.meeting.status == MeetingStatus.declined && !(widget.meeting.isInPast() || widget.meeting.isFinished))
                MeetingActionButton(
                  key: attendMeetingButtonKey,
                  text: "Attend Meeting",
                  onPressed: () async {
                    await showPopUpDialog(context, true);
                  },
                  backgroundColor: Colors.grey
                ),

              if (widget.meeting.status == MeetingStatus.declined && (widget.meeting.isInPast() || widget.meeting.isFinished))
                MeetingActionButton(
                  key: invitationDeclinedButtonKey,
                  text: "Invitation Declined",
                  onPressed: () {
                    CustomSnackBar.show(context, "Meeting is finished");
                  },
                  backgroundColor: Colors.grey
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
              if (showWithdrawOrDeleteButton)
                Center(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DeleteButton(
                      key: isAdmin ? deleteMeetingButtonKey : withdrawMeetingButtonKey,
                      str: isAdmin ? 'Delete Meeting' : 'Withdraw From Meeting',
                      showDeleteDialog: isAdmin ? showDeleteMeetingDialog : () {showPopUpDialog(context, false); },
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
