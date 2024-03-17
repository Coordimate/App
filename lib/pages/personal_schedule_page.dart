import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/main_navigation.dart';
import 'package:flutter/material.dart';

const gridBorderWidth = 1.0;
const gridBorderColor = Colors.grey;
const hourHeight = 36.0;

class _TimeColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: hourHeight / 2),
      for (var i = 1; i < 24; i++)
        SizedBox(
            height: hourHeight,
            child: Align(alignment: Alignment.topCenter, child: Text("$i:00"))),
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
              blurRadius: 20,
              spreadRadius: 1,
              offset: Offset(0, 1))
        ]),
        child: Row(children: [
          SizedBox(width: screenWidth / 8, height: hourHeight),
          for (var day in days)
            SizedBox(
                width: screenWidth / 8,
                height: hourHeight,
                child: Center(
                    child: Text(day,
                        style: const TextStyle(fontWeight: FontWeight.bold)))),
        ]));
  }
}

class _DayColumn extends StatelessWidget {
  final String day;

  const _DayColumn({required this.day});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
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
    ]);
  }
}

class PersonalSchedulePage extends StatelessWidget {
  PersonalSchedulePage({super.key});

  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
        body: Column(children: [
          _DaysRow(),
          Expanded(
              child: SingleChildScrollView(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                SizedBox(width: screenWidth / 8, child: _TimeColumn()),
                for (var day in days)
                  SizedBox(width: screenWidth / 8, child: _DayColumn(day: day)),
              ])))
        ]),
        bottomNavigationBar: BottomIcons());
  }
}
