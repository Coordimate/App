import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/divider.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/meeting_tiles.dart';
import 'package:coordimate/components/calendar_day_box.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/keys.dart';
import 'dart:convert';
// import 'package:intl/intl.dart';
import 'package:coordimate/api_client.dart';
import 'package:coordimate/components/archive_scroll.dart';
import 'package:coordimate/pages/meetings_archive.dart';

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({
    super.key,
  });

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  // DateTime _selectedDate = DateTime.now();
  List<MeetingTileModel> meetings = [];

  // Future<void> _selectDate() async {
  //   final DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate,
  //     firstDate: DateTime(2022, 1),
  //     lastDate: DateTime(2025),
  //   );
  //   if (!mounted) {
  //     return;
  //   }
  //   if (pickedDate != null && pickedDate != _selectedDate) {
  //     final TimeOfDay? pickedTime = await showTimePicker(
  //       context: context,
  //       initialTime: TimeOfDay.fromDateTime(_selectedDate),
  //     );
  //     if (pickedTime != null) {
  //       setState(() {
  //         _selectedDate = DateTime(
  //           pickedDate.year,
  //           pickedDate.month,
  //           pickedDate.day,
  //           pickedTime.hour,
  //           pickedTime.minute,
  //         );
  //       });
  //     }
  //   }
  // }

  // Future<void> _createMeeting() async {
  //   final response = await client.post(
  //     Uri.parse("$apiUrl/meetings/"),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       'title': _titleController.text,
  //       'start': _selectedDate.toIso8601String(),
  //       'description': _descriptionController.text,
  //       'group_id': '1',
  //     }),
  //   );
  //   if (response.statusCode == 201) {
  //     _fetchMeetings();
  //   } else {
  //     throw Exception('Failed to create meeting');
  //   }
  // }

  void clearControllers() {
    _titleController.clear();
    _descriptionController.clear();
    // _selectedDate = DateTime.now();
  }

  // void _onCreateMeeting() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return AlertDialog(
  //             title: const Text('Create Meeting'),
  //             content: SingleChildScrollView(
  //               child: ListBody(
  //                 children: <Widget>[
  //                   TextField(
  //                     controller: _titleController,
  //                     decoration: const InputDecoration(
  //                       labelText: 'Title',
  //                       hintText: 'Enter the title of the meeting',
  //                     ),
  //                   ),
  //                   ListTile(
  //                     title: Text(DateFormat('EEE, MMMM d, HH:mm')
  //                         .format(_selectedDate.toLocal())),
  //                     trailing: const Icon(Icons.keyboard_arrow_down),
  //                     onTap: () async {
  //                       await _selectDate();
  //                       setState(
  //                           () {}); // Rebuild the dialog to update the date
  //                     },
  //                   ),
  //                   TextField(
  //                     controller: _descriptionController,
  //                     decoration: const InputDecoration(
  //                       labelText: 'Description',
  //                       hintText: 'Enter the description of the meeting',
  //                     ),
  //                     maxLines: 3,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             actions: <Widget>[
  //               TextButton(
  //                 child: const Text('Cancel'),
  //                 onPressed: () {
  //                   clearControllers();
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //               TextButton(
  //                 child: const Text('Create'),
  //                 onPressed: () {
  //                   _createMeeting();
  //                   clearControllers();
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
  }

  Future<void> _fetchMeetings() async {
    final response = await client.get(Uri.parse("$apiUrl/meetings"));
    if (response.statusCode == 200) {
      if (!mounted) {
        return;
      }
      setState(() {
        meetings = (json.decode(response.body)['meetings'] as List)
            .map((data) => MeetingTileModel.fromJson(data))
            .toList();
        for (var meeting in meetings
            .where((meeting) => meeting.status == MeetingStatus.needsAcceptance)
            .toList()) {
          if (meeting.dateTime.isBefore(DateTime.now())) {
            _answerInvitation(meeting.id, false, showSnackBar: false);
          }
        }
        meetings.sort((a, b) =>
            a.dateTime.difference(DateTime.now()).inSeconds.abs() -
            b.dateTime.difference(DateTime.now()).inSeconds.abs());
      });
    } else {
      throw Exception('Failed to load meetings');
    }
  }

  Future<void> _answerInvitation(String id, bool accept,
      {bool showSnackBar = true}) async {
    String status = 'accepted';
    if (!accept) {
      status = 'declined';
    }
    final response = await client.patch(Uri.parse("$apiUrl/invites/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, dynamic>{
          'status': status,
        }));
    if (!mounted) {
      return;
    }
    if (response.statusCode == 200) {
      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Meeting $status")),
        );
      }
      _fetchMeetings();
    } else {
      throw Exception('Failed to answer invitation');
    }
  }

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    List<MeetingTileModel> declinedMeetings = meetings
        .where((meeting) => meeting.status == MeetingStatus.declined)
        .toList();
    List<MeetingTileModel> newInvitations = meetings
        .where((meeting) => meeting.status == MeetingStatus.needsAcceptance)
        .toList();
    List<MeetingTileModel> acceptedMeetings = meetings
        .where((meeting) => meeting.status == MeetingStatus.accepted)
        .toList();
    List<MeetingTileModel> acceptedPassedMeetings = acceptedMeetings
        .where((meeting) => meeting.dateTime.isBefore(DateTime.now()))
        .toList();
    List<MeetingTileModel> acceptedFutureMeetings = acceptedMeetings
        .where((meeting) => meeting.dateTime.isAfter(DateTime.now()))
        .toList();
    List<MeetingTileModel> archivedMeetings =
        acceptedPassedMeetings + declinedMeetings;
    archivedMeetings.sort((a, b) => b.dateTime.compareTo(a.dateTime));

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
          DraggableBottomSheet(
            initialChildSize: initialChildSize,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List<DateTime>.generate(
                          5, (i) => DateTime.now().add(Duration(days: i)))
                      .map(
                        (date) => CalendarDayBox(
                          date: date,
                          isSelected: selectedDate.day ==
                              date.day, // Pass isSelected based on selectedDate
                          onSelected: (selectedDate) {
                            setState(() {
                              this.selectedDate =
                                  selectedDate; // Update the selected date
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
            meeting: meetings[index],
            onAccepted: () => _answerInvitation(meetings[index].id, true),
            onDeclined: () => _answerInvitation(meetings[index].id, false),
            fetchMeetings: _fetchMeetings,
          );
        } else if (meetings[index].dateTime.day == selectedDate.day &&
            meetings[index].dateTime.month == selectedDate.month &&
            meetings[index].dateTime.year == selectedDate.year) {
          return AcceptedMeetingTile(
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
            // Build meeting tile based on meeting status
            if (meetings[index].status == MeetingStatus.needsAcceptance) {
              return NewMeetingTile(
                meeting: meetings[index],
                onAccepted: () => _answerInvitation(meetings[index].id, true),
                onDeclined: () => _answerInvitation(meetings[index].id, false),
                fetchMeetings: _fetchMeetings,
              );
            } else if (meetings[index].status == MeetingStatus.declined) {
              return ArchivedMeetingTile(
                meeting: meetings[index],
                fetchMeetings: _fetchMeetings,
              );
            } else {
              return AcceptedMeetingTile(
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

class DraggableBottomSheet extends StatefulWidget {
  final Widget child;
  final double initialChildSize;

  const DraggableBottomSheet({
    super.key,
    required this.child,
    required this.initialChildSize,
  });

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  final sheet = GlobalKey();
  final controller = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    controller.addListener(onChanged);
  }

  void collapse() => animateSheet(getSheet.snapSizes!.first);
  void expand() => animateSheet(getSheet.maxChildSize);
  void anchor() => animateSheet(getSheet.snapSizes!.last);
  void hide() => animateSheet(getSheet.minChildSize);

  void animateSheet(double value) {
    controller.animateTo(
      value,
      duration: const Duration(microseconds: 50),
      curve: Curves.easeInOut,
    );
  }

  DraggableScrollableSheet get getSheet =>
      sheet.currentWidget as DraggableScrollableSheet;

  void onChanged() {
    final currentSize = controller.size;
    if (currentSize <= 0.25) collapse();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (builder, constraints) {
      return DraggableScrollableSheet(
          key: sheet,
          initialChildSize: widget.initialChildSize,
          maxChildSize: 0.985,
          minChildSize: widget.initialChildSize,
          expand: true,
          snap: true,
          snapSizes: [
            widget.initialChildSize,
            0.985,
          ],
          builder: (BuildContext context, ScrollController scrollController) {
            return DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: darkBlue,
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  topButtonIndicator(),
                  SliverToBoxAdapter(
                    child: widget.child,
                  ),
                ],
              ),
            );
          });
    });
  }

  SliverToBoxAdapter topButtonIndicator() {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Wrap(
              children: [
                Container(
                  width: 100,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 5,
                  decoration: BoxDecoration(
                    color: darkBlue,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
