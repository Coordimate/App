import 'package:coordimate/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/pages/personal_schedule_page.dart';
import 'package:coordimate/pages/meetings_page.dart';
import 'package:coordimate/pages/groups_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required Key key,
  }) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedScreen = 1;

  static final List<Widget> _screens = [
    const PersonalSchedulePage(),
    const MeetingsPage(),
    GroupsPage()
  ];

  void _onButtonPressed(int index) {
    setState(() {
      _selectedScreen = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _screens[_selectedScreen],
        bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.perm_contact_cal_outlined),
                  label: 'Schedule'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined), label: 'Meetings'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline), label: 'Groups')
            ],
            currentIndex: _selectedScreen,
            selectedItemColor: darkBlue,
            onTap: _onButtonPressed));
  }
}
