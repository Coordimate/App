import 'dart:convert';
import 'package:coordimate/components/colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:coordimate/components/join_group_dialog.dart';
import 'package:coordimate/pages/schedule_page.dart';
import 'package:coordimate/pages/meetings_page.dart';
import 'package:coordimate/pages/groups_page.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/app_state.dart';

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
        print("Error parsing change in uniLink");
      });
    } on PlatformException {
      print("Failed to get UniLink");
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
    final regex = RegExp(r'^/users/([0-9a-z]+)/time_slots$');
    final match = regex.firstMatch(uri.path);
    if (match != null) {
      final userId = match.group(1)!;
      final response = await AppState.authController.client.get(Uri.parse("$apiUrl/users/$userId"));
      if (response.statusCode == 200) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SchedulePage(ownerId: userId, ownerName: json.decode(response.body)["username"])));
      }
    }
  }

  Future<void> _tryParseGroupJoinLink(Uri uri) async {
    final regex = RegExp(r'^/groups/([0-9a-z]+)/join$');
    final match = regex.firstMatch(uri.path);
    if (match != null) {
      final groupId = match.group(1)!;
      final response = await AppState.authController.client.get(Uri.parse("$apiUrl/groups/$groupId"));
      if (response.statusCode == 200) {
        final group = Group.fromJson(json.decode(response.body));
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return JoinGroupDialog(
                  key: UniqueKey(), groupName: group.name, groupId: group.id);
            });
      }
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
    await FirebaseMessaging.instance.requestPermission();
    // await FirebaseMessaging.instance.getAPNSToken();
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await _setFcmToken(fcmToken);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      await _setFcmToken(fcmToken);
    });
  }

  Future<void> _setFcmToken(String fcmToken) async {
    await AppState.authController.client.post(Uri.parse('$apiUrl/enable_notifications'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: json.encode(<String, dynamic>{'fcm_token': fcmToken}));
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
