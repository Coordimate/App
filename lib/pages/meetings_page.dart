import 'package:flutter/material.dart';
// import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/main_navigation.dart';

class MeetingsPage extends StatefulWidget {
  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Main home screen for meetings"),
        ],
      ),
      bottomNavigationBar: BottomIcons(),
    );
  }
}