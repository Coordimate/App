import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/main_navigation.dart';
import 'package:flutter/material.dart';

const gridBorderWidth = 1.0;
const gridBorderColor = Colors.grey;
// const hourHeight = 40.0;

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
              Expanded(
                  child: SingleChildScrollView(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                    SizedBox(
                        width: screenWidth / 8,
                        child: _TimeColumn(hourHeight: _hourHeight)),
                    for (var i = 0; i < 7; i++)
                      SizedBox(
                          width: screenWidth / 8,
                          child: _DayColumn(hourHeight: _hourHeight)),
                  ])))
            ]))));
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
      // SizedBox(height: hourHeight / 2),
      for (var i = 1; i < 24; i++)
        SizedBox(
            height: hourHeight,
            child: Align(alignment: Alignment.center, child: Text("$i:00"))),
    ]);
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
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
      _TimeSlot(hourHeight: hourHeight, startHour: 1.0, lengthHours: 2.0),
      _TimeSlot(hourHeight: hourHeight, startHour: 3.5, lengthHours: 2.2),
    ]);
  }
}

class _TimeSlot extends StatelessWidget {
  const _TimeSlot({
    this.hourHeight = 20.0,
    this.startHour = 0.0,
    this.lengthHours = 0.0,
  });

  final double hourHeight;
  final double startHour;
  final double lengthHours;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
        top: hourHeight * startHour,
        height: hourHeight * lengthHours,
        child: Container(
            width: screenWidth / 8,
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.7))));
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
              onPressed: () {}, // TODO: settings popup
            ),
          ],
        ),
        body: const ScheduleGrid(),
        bottomNavigationBar: BottomIcons());
  }
}
