import 'dart:convert';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/main_navigation.dart';
import 'package:coordimate/models/time_slot.dart';
import 'package:coordimate/keys.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const gridBorderWidth = 1.0;
const gridBorderColor = Colors.grey;

class ScheduleGrid extends StatefulWidget {
  const ScheduleGrid({
    super.key,
  });

  @override
  State<ScheduleGrid> createState() => _ScheduleGridState();
}

class _ScheduleGridState extends State<ScheduleGrid> {
  double _baseHourHeight = 20.0;
  double _hourHeight = 20.0;

  Future<List<TimeSlot>> timeSlotsFuture = getTimeSlots();

  static Future<List<TimeSlot>> getTimeSlots() async {
    var url = Uri.parse("$apiUrl/time_slots");
    final response =
        await http.get(url, headers: {"Content-Type": "application/json"});
    final List body = json.decode(response.body)['result'];
    return body.map((e) => TimeSlot.fromJson(e)).toList();
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
              FutureBuilder(
                  future: timeSlotsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasData) {
                      final timeSlots = snapshot.data!;
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
                                      hourHeight: _hourHeight,
                                      timeSlots: timeSlots
                                          .where((x) => x.day == i)
                                          .toList())),
                          ])));
                    } else {
                      return const Text("No data available");
                    }
                  })
            ]))));
  }

  Widget buildTimeSlots(List<TimeSlot> timeSlots) {
    final screenWidth = MediaQuery.of(context).size.width;
    const hourHeight = 40;

    return Column(children: [
      for (var timeSlot in timeSlots)
        SizedBox(
            // Positioned(
            // top: hourHeight * timeSlot.start,
            height: hourHeight * timeSlot.length,
            child: Container(
                width: screenWidth / 8 - gridBorderWidth,
                decoration: BoxDecoration(color: orange.withOpacity(0.8))))
    ]);
  }
}

class _DaysRow extends StatelessWidget {
  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.grey,
              blurRadius: 5,
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
                    child: Text(day,
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
  List<TimeSlot> timeSlots;

  _DayColumn({
    required this.timeSlots,
    this.hourHeight = 20.0,
  });

  final double hourHeight;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(children: [
      Column(children: [
        for (var i = 0; i < 24; i++)
          SizedBox(
              height: hourHeight,
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: gridBorderWidth, color: gridBorderColor),
                        right: BorderSide(
                            width: gridBorderWidth, color: gridBorderColor))),
              )),
      ]),
      for (var timeSlot in timeSlots)
        Positioned(
            top: hourHeight * timeSlot.start,
            height: hourHeight * timeSlot.length,
            child: Container(
                width: screenWidth / 8 - gridBorderWidth,
                decoration: BoxDecoration(color: orange.withOpacity(0.8))))
      // TimeSlot(hourHeight: hourHeight, start: 1.0, length: 2.0),
      // TimeSlot(hourHeight: hourHeight, start: 3.5, length: 2.2),
    ]);
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
              onPressed: () {
                _ScheduleGridState.getTimeSlots();
              },
            ),
          ],
        ),
        body: const ScheduleGrid(),
        bottomNavigationBar: BottomIcons());
  }
}
