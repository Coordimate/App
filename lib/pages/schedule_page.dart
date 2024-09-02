import 'dart:convert';

import 'package:coordimate/pages/personal_info_page.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:flutter/material.dart';

import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/models/time_slot.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/components/create_meeting_dialog.dart';
import 'package:coordimate/app_state.dart';
import 'package:share_plus/share_plus.dart';

const gridBorderWidth = 1.0;
const gridBorderColor = gridGrey;
const List<String> days = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];

class ScheduleGrid extends StatefulWidget {
  const ScheduleGrid({
    super.key,
  });

  @override
  State<ScheduleGrid> createState() => ScheduleGridState();
}

class ScheduleGridState extends State<ScheduleGrid> {
  double _baseHourHeight = 26.0;
  double hourHeight = 26.0;
  Future<List<TimeSlot>>? _timeSlots;

  @override
  void initState() {
    super.initState();
    _timeSlots = AppState.scheduleController.getTimeSlots();
  }

  void refresh() {
    setState(() {
      _timeSlots = AppState.scheduleController.getTimeSlots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
        onScaleStart: (details) {
          _baseHourHeight = hourHeight;
        },
        onScaleUpdate: (details) {
          setState(() {
            hourHeight = _baseHourHeight * details.scale;
            if (hourHeight < 20) {
              hourHeight = 20.0;
            }
            if (hourHeight > 100) {
              hourHeight = 100.0;
            }
          });
        },
        child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(
                child: Column(children: [
              _DaysRow(),
              FutureBuilder<List<TimeSlot>>(
                  future: _timeSlots,
                  builder: (context, snapshot) {
                    return Expanded(
                        child: SingleChildScrollView(
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                          SizedBox(
                              width: screenWidth / 8,
                              child: TimeColumn(hourHeight: hourHeight)),
                          for (var i = 0; i < 7; i++)
                            SizedBox(
                                width: screenWidth / 8,
                                child: DayColumn(
                                    day: i,
                                    hourHeight: hourHeight,
                                    refresh: refresh,
                                    timeSlots: snapshot.hasData
                                        ? snapshot.data!
                                            .where((x) => x.day == i)
                                            .toList()
                                        : [])),
                        ])));
                  })
            ]))));
  }
}

class _DaysRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.grey,
              blurRadius: 2,
              spreadRadius: 1,
              offset: Offset(0, 1))
        ]),
        child: Row(children: [
          SizedBox(width: screenWidth / 8, height: 25),
          for (var day in days)
            SizedBox(
                width: screenWidth / 8,
                height: 25,
                child: Center(
                    child: Text(day.substring(0, 3),
                        style: const TextStyle(fontWeight: FontWeight.bold)))),
        ]));
  }
}

class TimeColumn extends StatelessWidget {
  const TimeColumn({
    super.key,
    this.hourHeight = 20.0,
  });

  final double hourHeight;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (var i = 1; i < 24; i++)
        SizedBox(
            height: hourHeight,
            child: Align(alignment: Alignment.center, child: Text("$i:00"))),
    ]);
  }
}

class DayColumn extends StatelessWidget {
  final List<TimeSlot> timeSlots;
  final int day;
  final double hourHeight;
  final Function refresh;
  final GlobalKey<NewTimeSlotState> _newTimeSlotKey =
      GlobalKey<NewTimeSlotState>();

  DayColumn({
    super.key,
    required this.timeSlots,
    required this.day,
    required this.refresh,
    this.hourHeight = 20.0,
  });

  double roundToFraction(double hours) {
    var fraction = 1;
    if (hourHeight <= 30) {
      fraction = 1;
    } else if (hourHeight <= 50) {
      fraction = 2;
    } else {
      fraction = 4;
    }
    return (hours / (hourHeight / fraction) + 0.5).floor() *
        (hourHeight / fraction);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      NewTimeSlot(key: _newTimeSlotKey),
      GestureDetector(
          onLongPressStart: (details) {
            if (!AppState.scheduleController.isModifiable) {
              return;
            }
            _newTimeSlotKey.currentState
                ?.updateStart(roundToFraction(details.localPosition.dy));
          },
          onLongPressMoveUpdate: (details) {
            if (!AppState.scheduleController.isModifiable) {
              return;
            }
            var start = _newTimeSlotKey.currentState?.start ?? 0.0;
            if (details.localPosition.dy < start) {
              _newTimeSlotKey.currentState
                  ?.updateTop(roundToFraction(details.localPosition.dy));
              _newTimeSlotKey.currentState?.updateHeight(
                  roundToFraction(start - details.localPosition.dy));
            } else {
              _newTimeSlotKey.currentState?.updateTop(start);
              _newTimeSlotKey.currentState?.updateHeight(
                  roundToFraction(details.localPosition.dy - start));
            }
          },
          onLongPressEnd: (details) async {
            if (!AppState.scheduleController.isModifiable) {
              return;
            }
            final start = _newTimeSlotKey.currentState!.top / hourHeight;
            final length = _newTimeSlotKey.currentState!.height / hourHeight;
            await AppState.scheduleController
                .createTimeSlot(day, start, length);
            refresh();
            _newTimeSlotKey.currentState?.updateTop(0);
            _newTimeSlotKey.currentState?.updateHeight(0);
          },
          child: Column(children: [
            for (var i = 0; i < 24; i++)
              GestureDetector(
                  onTap: () async {
                    if (AppState.scheduleController.canCreateMeeting) {
                      var now = DateTime.now();
                      var weekStart = now.subtract(Duration(
                          days: now.weekday - 1,
                          hours: now.hour,
                          minutes: now.minute));
                      var picked = weekStart.add(Duration(days: day, hours: i));
                      showDialog(
                          context: context,
                          builder: (context) {
                            return CreateMeetingDialog(
                                groupId: AppState.scheduleController.ownerId,
                                pickedDate: (now.isAfter(picked))
                                    ? picked.add(const Duration(days: 7))
                                    : picked);
                          }).then((_) {
                        refresh();
                      });
                    } else if (AppState.scheduleController.isModifiable) {
                      await AppState.scheduleController
                          .createTimeSlot(day, i.toDouble(), 1.0);
                      refresh();
                      _newTimeSlotKey.currentState?.updateTop(0);
                      _newTimeSlotKey.currentState?.updateHeight(0);
                    }
                  },
                  child: SizedBox(
                      height: hourHeight,
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: gridBorderWidth,
                                    color: (i != 23)
                                        ? gridBorderColor
                                        : Colors.white),
                                right: BorderSide(
                                    width: gridBorderWidth,
                                    color: (day != 6)
                                        ? gridBorderColor
                                        : Colors.white))),
                      ))),
          ])),
      for (var timeSlot in timeSlots.where((e) => e.day == day).toList())
        TimeSlotWidget(
            id: timeSlot.id,
            day: day,
            isMeeting: timeSlot.isMeeting,
            hourHeight: hourHeight,
            start: timeSlot.start,
            length: timeSlot.length,
            refresh: refresh)
    ]);
  }
}

class TimeSlotWidget extends StatelessWidget {
  const TimeSlotWidget({
    super.key,
    required this.id,
    required this.day,
    required this.isMeeting,
    required this.start,
    required this.length,
    required this.hourHeight,
    required this.refresh,
  });

  final String id;
  final int day;
  final bool isMeeting;
  final double start;
  final double length;
  final double hourHeight;
  final Function refresh;

  Widget buildTimePickerPopup(BuildContext context, int day) {
    return TimePicker(
        id: id, day: day, start: start, length: length, refresh: refresh);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
        top: hourHeight * start,
        height: hourHeight * length,
        child: GestureDetector(
            onTap: () {
              if (!AppState.scheduleController.isModifiable) {
                if (AppState.scheduleController.canCreateMeeting) {}
                return;
              }
              showDialog(
                  context: context,
                  builder: (context) => buildTimePickerPopup(context, day));
            },
            child: Stack(children: [
              Container(
                  width: screenWidth / 8 - gridBorderWidth,
                  decoration: BoxDecoration(
                      color: isMeeting
                          ? darkBlue.withOpacity(0.7)
                          : orange.withOpacity(0.7)))
            ])));
  }
}

class TimePicker extends StatefulWidget {
  const TimePicker({
    super.key,
    required this.id,
    required this.day,
    required this.start,
    required this.length,
    required this.refresh,
  });

  final String id;
  final int day;
  final double start;
  final double length;
  final Function refresh;

  @override
  State<TimePicker> createState() => TimePickerState();
}

class TimePickerState extends State<TimePicker> {
  double newStart = 0.0;
  double newLength = 0.0;
  String startTimeString = "";
  String endTimeString = "";

  static TimeOfDay hoursToTime(double hours) {
    return TimeOfDay(hour: hours.floor(), minute: ((hours % 1) * 60).floor());
  }

  static String timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static double timeToHours(TimeOfDay time) {
    return time.hour + time.minute / 60;
  }

  @override
  void initState() {
    super.initState();
    startTimeString = timeToString(hoursToTime(widget.start));
    endTimeString = timeToString(hoursToTime(widget.start + widget.length));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Align(
          alignment: Alignment.center,
          child: Text(days[widget.day],
              style: const TextStyle(fontWeight: FontWeight.bold))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            const SizedBox(
                width: 50,
                child: Center(
                    child: Text("from", style: TextStyle(fontSize: 20)))),
            GestureDetector(
                onTap: () async {
                  if (!AppState.scheduleController.isModifiable) {
                    return;
                  }
                  final TimeOfDay? time = await showTimePicker(
                      initialTime: hoursToTime(widget.start), context: context);
                  if (time != null &&
                      timeToHours(time) < widget.start + widget.length) {
                    setState(() {
                      newStart = timeToHours(time);
                      startTimeString = timeToString(hoursToTime(newStart));
                    });
                    await AppState.scheduleController.updateTimeSlot(
                        widget.id,
                        widget.day,
                        newStart,
                        widget.length + widget.start - newStart);
                    widget.refresh();
                  }
                },
                child: Container(
                    key: startTimeSlot,
                    width: 90,
                    decoration: BoxDecoration(
                        border: Border.all(color: darkBlue),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: Center(
                        child: Text(startTimeString,
                            style: const TextStyle(
                                fontSize: 26, fontWeight: FontWeight.w600))))),
          ]),
          const Divider(color: Colors.grey, height: 40),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            const SizedBox(
                width: 50,
                child:
                    Center(child: Text("to", style: TextStyle(fontSize: 20)))),
            GestureDetector(
                onTap: () async {
                  if (!AppState.scheduleController.isModifiable) {
                    return;
                  }
                  final TimeOfDay? time = await showTimePicker(
                      initialTime: hoursToTime(widget.start + widget.length),
                      context: context);
                  if (time != null && timeToHours(time) > widget.start) {
                    setState(() {
                      newLength = timeToHours(time) - widget.start;
                      endTimeString =
                          timeToString(hoursToTime(widget.start + newLength));
                    });
                    await AppState.scheduleController.updateTimeSlot(
                        widget.id, widget.day, widget.start, newLength);
                    widget.refresh();
                  }
                },
                child: Container(
                    key: endTimeSlot,
                    width: 90,
                    decoration: BoxDecoration(
                        border: Border.all(color: darkBlue),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: Center(
                        child: Text(endTimeString,
                            style: const TextStyle(
                                fontSize: 26, fontWeight: FontWeight.w600))))),
          ]),
          const SizedBox(height: 30),
          Center(
              child: ElevatedButton(
                  key: deleteTimeSlotKey,
                  style: const ButtonStyle(
                      side: WidgetStatePropertyAll(
                          BorderSide(color: Colors.red))),
                  onPressed: () async {
                    if (!AppState.scheduleController.isModifiable) {
                      return;
                    }
                    await AppState.scheduleController.deleteTimeSlot(widget.id);
                    widget.refresh();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Delete',
                      style: TextStyle(color: Colors.red))))
        ],
      ),
    );
  }
}

class NewTimeSlot extends StatefulWidget {
  const NewTimeSlot({
    super.key,
  });

  @override
  State<NewTimeSlot> createState() => NewTimeSlotState();
}

class NewTimeSlotState extends State<NewTimeSlot> {
  double top = 0.0;
  double height = 0.0;
  double start = 0.0;

  void updateTop(double top_) {
    setState(() {
      top = top_;
    });
  }

  void updateHeight(double height_) {
    setState(() {
      height = height_;
    });
  }

  void updateStart(double start_) {
    setState(() {
      start = start_;
      top = start_;
      height = 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
      top: top,
      height: height,
      child: Container(
          width: screenWidth / 8 - gridBorderWidth,
          decoration: BoxDecoration(color: orange.withOpacity(0.5))),
    );
  }
}

class SchedulePage extends StatelessWidget {
  const SchedulePage({
    super.key,
    this.ownerId = "",
    this.ownerName = "",
    this.isGroupSchedule = false,
  });

  final bool isGroupSchedule;
  final String ownerId;
  final String ownerName;

  Future<void> shareSchedule() async {
    var url = Uri.parse("$apiUrl/share_schedule");
    final response = await AppState.client
        .get(url, headers: {"Content-Type": "application/json"});
    if (response.statusCode != 200) {
      throw Exception('Failed to share schedule');
    }
    final body = json.decode(response.body)['schedule_link'].toString();
    Share.share(body);
  }

  @override
  Widget build(BuildContext context) {
    AppState.scheduleController.ownerId = ownerId;
    if (isGroupSchedule) {
      AppState.scheduleController.setScheduleParams(
          "$apiUrl/groups/$ownerId/time_slots",
          (ownerName == "") ? "Group Schedule" : ownerName,
          false,
          true);
    } else if (ownerId != "") {
      AppState.scheduleController.setScheduleParams(
          "$apiUrl/users/$ownerId/time_slots",
          (ownerName == "") ? "User Schedule" : ownerName,
          false,
          false);
    } else {
      AppState.scheduleController
          .setScheduleParams("$apiUrl/time_slots", "Schedule", true, false);
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
            title: AppState.scheduleController.pageTitle,
            needButton: (ownerId == ""),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PersonalPage()));
            },
            buttonIcon: Icons.settings_outlined),
        body: const ScheduleGrid(),
        floatingActionButton: (ownerId == "")
            ? FloatingActionButton(
                onPressed: () async {
                  await shareSchedule();
                },
                backgroundColor: mediumBlue,
                child: const Icon(Icons.share, color: Colors.white),
              )
            : null);
  }
}
