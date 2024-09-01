import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/divider.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/meeting_tiles.dart';
import 'package:coordimate/components/calendar_day_box.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/archive_scroll.dart';
import 'package:coordimate/pages/meetings_archive.dart';
import 'package:coordimate/components/snack_bar.dart';
import 'package:coordimate/components/draggable_bottom_sheet.dart';

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({
    super.key,
  });

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  List<MeetingTileModel> meetings = [];

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
  }

  Future<void> _fetchMeetings() async {
    final meetingsFetched = await AppState.meetingController.fetchMeetings();
      setState(() {
        meetings = meetingsFetched;
      });
  }

  Future<void> _answerInvitation(String id, bool accept,
      {bool showSnackBar = true}) async {
    final status = await AppState.meetingController.answerInvitation(accept, id);
    if (showSnackBar && mounted) {
      status == MeetingStatus.accepted
        ? CustomSnackBar.show(context, "Meeting accepted")
        : CustomSnackBar.show(context, "Meeting declined");
    }
    _fetchMeetings();
  }

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    List<MeetingTileModel> newInvitations = meetings
        .where((meeting) => meeting.status == MeetingStatus.needsAcceptance
        && !meeting.isFinished)
        .toList();
    List<MeetingTileModel> acceptedMeetings = meetings
        .where((meeting) => meeting.status == MeetingStatus.accepted
        && !meeting.isFinished)
        .toList();
    List<MeetingTileModel> acceptedFutureMeetings = acceptedMeetings
        .where((meeting) => meeting.dateTime.isAfter(DateTime.now())
        && !meeting.isFinished)
        .toList();
    List<MeetingTileModel> archivedMeetings = meetings
        .where((meeting) => meeting.status == MeetingStatus.declined
        || meeting.isFinished
        || meeting.isInPast())
        .toList();
    archivedMeetings.sort((a, b) =>
    b.dateTime.difference(DateTime.now()).inSeconds -
        a.dateTime.difference(DateTime.now()).inSeconds);

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double boxWidth = screenWidth / 5 * 0.85;
    double paddingBottom = 8.0; // space between calendar row and meeting list
    double initialChildSize =
        (boxWidth + paddingBottom + kBottomNavigationBarHeight - 3) /
            screenHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
          title: "Meetings", needButton: false),
      body: Stack(
        children: [
          Padding(
            key: meetingsScrollViewKey,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.1),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverHidedHeader(
                    child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  height: 50,
                  color: Colors.white,
                  child: Container(
                    key: archiveButtonKey,
                    padding: const EdgeInsets.only(left: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MeetingsArchivePage(
                                  meetings: archivedMeetings,
                                  fetchMeetings: _fetchMeetings)),
                        );
                      },
                      child: const Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.archive,
                              color: Colors.grey,
                              size: 30,
                            ),
                            SizedBox(width: 8),
                            Text("Archive",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
                SliverList(
                  delegate: SliverChildListDelegate([
                    // if (declinedMeetings.isNotEmpty) ...[
                    //   _buildMeetingList(declinedMeetings, "Declined Meetings"),
                    // ],
                    if (newInvitations.isNotEmpty) ...[
                      _buildMeetingList(newInvitations, "Invitations"),
                    ],
                    if (acceptedFutureMeetings.isNotEmpty) ...[
                      _buildMeetingList(
                          acceptedFutureMeetings, "Upcoming Meetings"),
                    ],
                  ]),
                ),
              ],
            ),
          ),
          if (!kIsWeb)
          DraggableBottomSheet(
            key: draggableBottomSheetKey,
            initialChildSize: initialChildSize,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List<DateTime>.generate(
                          5, (i) => DateTime.now().add(Duration(days: i)))
                      .map(
                        (date) => CalendarDayBox(
                          key: Key('calendarDayBox${date.day.toString()}'),
                          date: date,
                          isSelected: selectedDate.day == date.day,
                          onSelected: (selectedDate) {
                            setState(() {
                              this.selectedDate = selectedDate;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                if (newInvitations.isNotEmpty) ...[
                  _buildDailyMeetingList(newInvitations, selectedDate),
                ],
                if (acceptedMeetings.isNotEmpty) ...[
                  _buildDailyMeetingList(acceptedMeetings, selectedDate),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMeetingList(
      List<MeetingTileModel> meetings, DateTime selectedDate) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        if (meetings[index].dateTime.day == selectedDate.day &&
            meetings[index].dateTime.month == selectedDate.month &&
            meetings[index].dateTime.year == selectedDate.year &&
            meetings[index].status == MeetingStatus.needsAcceptance) {
          return NewMeetingTile(
            key: Key('newMeetingTile${meetings[index].id}'),
            meeting: meetings[index],
            onAccepted: () => _answerInvitation(meetings[index].id, true),
            onDeclined: () => _answerInvitation(meetings[index].id, false),
            fetchMeetings: _fetchMeetings,
          );
        } else if (meetings[index].dateTime.day == selectedDate.day &&
            meetings[index].dateTime.month == selectedDate.month &&
            meetings[index].dateTime.year == selectedDate.year) {
          return AcceptedMeetingTile(
            key: Key('acceptedMeetingTile${meetings[index].id}'),
            meeting: meetings[index],
            fetchMeetings: _fetchMeetings,
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildMeetingList(List<MeetingTileModel> meetings, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomDivider(text: title),
        const SizedBox(height: 16),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            if (meetings[index].status == MeetingStatus.needsAcceptance) {
              return NewMeetingTile(
                key: Key('newMeetingTile${meetings[index].id}'),
                meeting: meetings[index],
                onAccepted: () => _answerInvitation(meetings[index].id, true),
                onDeclined: () => _answerInvitation(meetings[index].id, false),
                fetchMeetings: _fetchMeetings,
              );
            } else if (meetings[index].status == MeetingStatus.accepted) {
              return AcceptedMeetingTile(
                key: Key('acceptedMeetingTile${meetings[index].id}'),
                meeting: meetings[index],
                fetchMeetings: _fetchMeetings,
              );
            }
          },
        ),
      ],
    );
  }
}

