import 'dart:developer';
import 'package:coordimate/components/colors.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:coordimate/components/join_group_dialog.dart';
import 'package:coordimate/pages/schedule_page.dart';
import 'package:coordimate/pages/meetings_page.dart';
import 'package:coordimate/pages/groups_page.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/widget_keys.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required Key key,
  }) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedScreen = 1;
  late StreamSubscription _sub = const Stream.empty().listen((_) {});

  static final List<Widget> _screens = [
    const SchedulePage(),
    const MeetingsPage(),
    const GroupsPage()
  ];

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> initUniLinks() async {
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        await _handleDeepLink(initialUri);
      }
      _sub = uriLinkStream.listen((Uri? link) async {
        if (link != null) {
          await _handleDeepLink(link);
        }
      }, onError: (err) {
        log("Error parsing change in uniLink");
      });
    } on PlatformException {
      log("Failed to get UniLink");
      return;
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    setState(() {
      switch (uri.path) {
        case '/schedule':
          _selectedScreen = 0;
          return;
        case '/meetings':
          _selectedScreen = 1;
          return;
        case '/groups':
          _selectedScreen = 2;
          return;
      }
    });
    await _tryParseGroupJoinLink(uri);
    await _tryParseUserScheduleLink(uri);
  }

  Future<void> _tryParseUserScheduleLink(Uri uri) async {
    final schedulePage = await AppState.scheduleController.tryParseUserScheduleLink(uri);
    if (schedulePage != null && mounted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => schedulePage));
    }
  }

  Future<void> _tryParseGroupJoinLink(Uri uri) async {
    final group = await AppState.scheduleController.tryParseGroupJoinLink(uri);
    if (group != null && mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return JoinGroupDialog(
              key: UniqueKey(), groupName: group.name, groupId: group.id);
        });
    }
  }

  void _onButtonPressed(int index) {
    setState(() {
      _selectedScreen = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNotifications();
    });
    initUniLinks().whenComplete(() {});
  }

  void _initNotifications() async {
    await AppState.firebaseMessagingInstance.requestPermission();
    // await FirebaseMessaging.instance.getAPNSToken();
    final fcmToken = await AppState.firebaseMessagingInstance.getToken();
    if (fcmToken != null) {
      await AppState.userController.setFcmToken(fcmToken);
    }
    AppState.firebaseMessagingInstance.onTokenRefresh.listen((fcmToken) async {
      await AppState.userController.setFcmToken(fcmToken);
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
            key: bottomNavigationBarKey,
              backgroundColor: Colors.white,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  key: scheduleNavigationButtonKey,
                  icon: Icon(Icons.perm_contact_cal_outlined),
                  label: 'Schedule'),
                BottomNavigationBarItem(
                  key: meetingsNavigationButtonKey,
                  icon: Icon(Icons.home_outlined),
                  label: 'Meetings'),
                BottomNavigationBarItem(
                  key: groupsNavigationButtonKey,
                  icon: Icon(Icons.people_outline),
                  label: 'Groups')
              ],
              currentIndex: _selectedScreen,
              selectedItemColor: darkBlue,
              onTap: _onButtonPressed),
        ));
  }
}
