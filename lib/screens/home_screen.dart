import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:coordimate/components/colors.dart';
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
  late StreamSubscription _sub;

  static final List<Widget> _screens = [
    const PersonalSchedulePage(),
    const MeetingsPage(),
    const GroupsPage()
  ];

  @override
  void initState() {
    super.initState();
    initUniLinks().whenComplete(() {});
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> initUniLinks() async {
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
      _sub = uriLinkStream.listen((Uri? link) {
        if (link != null) {
          _handleDeepLink(link);
        }
      }, onError: (err) {
        print("Error parsing change in uniLink");
      });
    } on PlatformException {
      print("Failed to get UniLink");
      return;
    }
  }

  void _handleDeepLink(Uri uri) {
    setState(() {
      switch (uri.path) {
        case '/schedule':
          _selectedScreen = 0;
          break;
        case '/meetings':
          _selectedScreen = 1;
          break;
        case '/groups':
          _selectedScreen = 2;
          break;
      }
    });
  }

  void _onButtonPressed(int index) {
    setState(() {
      _selectedScreen = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _screens[_selectedScreen],
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: alphaDarkBlue,
                spreadRadius: 1,
                blurRadius: 7,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: BottomNavigationBar(
              backgroundColor: Colors.white,
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
              onTap: _onButtonPressed),
        ));
  }
}
