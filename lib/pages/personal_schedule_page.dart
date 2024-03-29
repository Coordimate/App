import 'dart:convert';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/main_navigation.dart';
import 'package:coordimate/models/time_slot.dart';
import 'package:coordimate/keys.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  State<ScheduleGrid> createState() => _ScheduleGridState();
}

class _ScheduleGridState extends State<ScheduleGrid> {
  double _baseHourHeight = 26.0;
  double _hourHeight = 26.0;
  Future<List<TimeSlot>>? _timeSlots;

  @override
  void initState() {
    super.initState();
    _timeSlots = getTimeSlots();
  }

  Future<List<TimeSlot>> getTimeSlots() async {
    var url = Uri.parse("$apiUrl/time_slots/");
    final response =
        await http.get(url, headers: {"Content-Type": "application/json"});
    final List body = json.decode(response.body)['time_slots'];
    return body.map((e) => TimeSlot.fromJson(e)).toList();
  }

  Future<void> createTimeSlot(int day, double start, double length) async {
    await http.post(Uri.parse("$apiUrl/time_slots/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(<String, dynamic>{
          'is_meeting': false,
          'day': day,
          'start': start.toStringAsFixed(2),
          'length': length.toStringAsFixed(2)
        }));
    setState(() {
      _timeSlots = getTimeSlots();
    });
  }

  Future<void> deleteTimeSlot(String id) async {
    await http.delete(Uri.parse("$apiUrl/time_slots/$id"),
        headers: {"Content-Type": "application/json"});
    setState(() {
      _timeSlots = getTimeSlots();
    });
  }

  Future<void> updateTimeSlot(String id, double start, double length) async {
    await http.patch(Uri.parse("$apiUrl/time_slots/$id"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(<String, dynamic>{
          'id': id,
          'start': start.toStringAsFixed(2),
          'length': length.toStringAsFixed(2)
        }));
    setState(() {
      _timeSlots = getTimeSlots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
        onScaleStart: (details) {
          _baseHourHeight = _hourHeight;
        },
        onScaleUpdate: (details) {
          setState(() {
            _hourHeight = _baseHourHeight * details.scale;
            if (_hourHeight < 20) {
              _hourHeight = 20.0;
            }
            if (_hourHeight > 100) {
              _hourHeight = 100.0;
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
                              child: _TimeColumn(hourHeight: _hourHeight)),
                          for (var i = 0; i < 7; i++)
                            SizedBox(
                                width: screenWidth / 8,
                                child: _DayColumn(
                                    day: i,
                                    hourHeight: _hourHeight,
                                    createTimeSlot: createTimeSlot,
                                    deleteTimeSlot: deleteTimeSlot,
                                    updateTimeSlot: updateTimeSlot,
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

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
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

class _DayColumn extends StatelessWidget {
  final void Function(int day, double start, double length) createTimeSlot;
  final void Function(String id, double start, double length) updateTimeSlot;
  final void Function(String id) deleteTimeSlot;

  final List<TimeSlot> timeSlots;
  final int day;
  final double hourHeight;
  final GlobalKey<_NewTimeSlotState> _newTimeSlotKey =
      GlobalKey<_NewTimeSlotState>();

  _DayColumn({
    required this.createTimeSlot,
    required this.deleteTimeSlot,
    required this.updateTimeSlot,
    required this.timeSlots,
    required this.day,
    this.hourHeight = 20.0,
  });

  // Round to fraction of an hour based on current hour height
  double roundToFraction(double hours) {
    var fraction = 1;
    if (hourHeight <= 30) {
      fraction = 2;
    } else if (hourHeight <= 50) {
      fraction = 4;
    } else {
      fraction = 6;
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
            _newTimeSlotKey.currentState
                ?.updateStart(roundToFraction(details.localPosition.dy));
          },
          onLongPressMoveUpdate: (details) {
            var start = _newTimeSlotKey.currentState?._start ?? 0.0;
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
          onLongPressEnd: (details) {
            final start = _newTimeSlotKey.currentState!._top / hourHeight;
            final length = _newTimeSlotKey.currentState!._height / hourHeight;
            createTimeSlot(day, start, length);
            _newTimeSlotKey.currentState?.updateTop(0);
            _newTimeSlotKey.currentState?.updateHeight(0);
          },
          child: Column(children: [
            for (var i = 0; i < 24; i++)
              SizedBox(
                  height: hourHeight,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                width: gridBorderWidth,
                                color:
                                    (i != 23) ? gridBorderColor : Colors.white),
                            right: BorderSide(
                                width: gridBorderWidth,
                                color: (day != 6)
                                    ? gridBorderColor
                                    : Colors.white))),
                  )),
          ])),
      for (var timeSlot in timeSlots.where((e) => e.day == day).toList())
        TimeSlotWidget(
            id: timeSlot.id,
            day: day,
            hourHeight: hourHeight,
            start: timeSlot.start,
            length: timeSlot.length,
            deleteTimeSlot: deleteTimeSlot,
            updateTimeSlot: updateTimeSlot)
    ]);
  }
}

class TimeSlotWidget extends StatelessWidget {
  const TimeSlotWidget({
    super.key,
    required this.id,
    required this.day,
    required this.start,
    required this.length,
    required this.hourHeight,
    required this.deleteTimeSlot,
    required this.updateTimeSlot,
  });

  final String id;
  final int day;
  final double start;
  final double length;
  final double hourHeight;
  final void Function(String id) deleteTimeSlot;
  final void Function(String id, double start, double length) updateTimeSlot;

  Widget _buildTimePickerPopup(BuildContext context, int day) {
    return _TimePicker(
        id: id,
        day: day,
        start: start,
        length: length,
        updateTimeSlot: updateTimeSlot,
        deleteTimeSlot: deleteTimeSlot);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
        top: hourHeight * start,
        height: hourHeight * length,
        child: GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => _buildTimePickerPopup(context, day));
            },
            child: Container(
                width: screenWidth / 8 - gridBorderWidth,
                decoration: BoxDecoration(color: orange.withOpacity(0.7)))));
  }
}

class _TimePicker extends StatefulWidget {
  const _TimePicker({
    required this.id,
    required this.day,
    required this.start,
    required this.length,
    required this.deleteTimeSlot,
    required this.updateTimeSlot,
  });

  final String id;
  final int day;
  final double start;
  final double length;
  final void Function(String id) deleteTimeSlot;
  final void Function(String id, double start, double length) updateTimeSlot;

  @override
  State<_TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<_TimePicker> {
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
                  final TimeOfDay? time = await showTimePicker(
                      initialTime: hoursToTime(widget.start), context: context);
                  if (time != null &&
                      timeToHours(time) < widget.start + widget.length) {
                    setState(() {
                      newStart = timeToHours(time);
                      startTimeString = timeToString(hoursToTime(newStart));
                    });
                    widget.updateTimeSlot(widget.id, newStart,
                        widget.length + widget.start - newStart);
                  }
                },
                child: Container(
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
                  final TimeOfDay? time = await showTimePicker(
                      initialTime: hoursToTime(widget.start + widget.length),
                      context: context);
                  if (time != null && timeToHours(time) > widget.start) {
                    setState(() {
                      newLength = timeToHours(time) - widget.start;
                      endTimeString =
                          timeToString(hoursToTime(widget.start + newLength));
                    });
                    widget.updateTimeSlot(widget.id, widget.start, newLength);
                  }
                },
                child: Container(
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
                  style: const ButtonStyle(
                      side: MaterialStatePropertyAll(
                          BorderSide(color: Colors.red))),
                  onPressed: () {
                    widget.deleteTimeSlot(widget.id);
                    Navigator.of(context).pop();
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
  State<NewTimeSlot> createState() => _NewTimeSlotState();
}

class _NewTimeSlotState extends State<NewTimeSlot> {
  double _top = 0.0;
  double _height = 0.0;
  double _start = 0.0;

  void updateTop(double top) {
    setState(() {
      _top = top;
    });
  }

  void updateHeight(double height) {
    setState(() {
      _height = height;
    });
  }

  void updateStart(double start) {
    setState(() {
      _start = start;
      _top = start;
      _height = 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
      top: _top,
      height: _height,
      child: Container(
          width: screenWidth / 8 - gridBorderWidth,
          decoration: BoxDecoration(color: orange.withOpacity(0.5))),
    );
  }
}

class PersonalSchedulePage extends StatelessWidget {
  const PersonalSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: mediumBlue,
          title: const Text(
            'Personal Schedule',
            style: TextStyle(color: white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              color: Colors.white,
              onPressed: () {},
            ),
          ],
        ),
        body: const ScheduleGrid(),
        bottomNavigationBar: NavBar(key: UniqueKey()));
  }
}
