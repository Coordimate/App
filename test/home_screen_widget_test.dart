import 'package:coordimate/pages/groups_page.dart';
import 'package:coordimate/pages/meetings_page.dart';
import 'package:coordimate/pages/schedule_page.dart';
import 'package:coordimate/screens/home_screen.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/client/groups.dart';
import 'helpers/set_appstate.dart';
import 'helpers/when.dart';
import 'home_screen_widget_test.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage, SharedPreferences, FirebaseMessaging])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final firebase = MockFirebaseMessaging();
  final client = MockClient();
  final storage = MockFlutterSecureStorage();
  final sharedPrefs = MockSharedPreferences();

  setAppState(client, storage, sharedPrefs, firebase);
  whenStatements(client, storage, sharedPrefs, firebase);

  group('Open pages', ()
  {
    testWidgets('Open MeetingsPage', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MeetingsPage(),
      ));

      expect(find.text('Meetings'), findsAtLeast(1));
    });

    testWidgets('Open GroupsPage', (tester) async {
      whenGroupsNone(client);

      await tester.pumpWidget(const MaterialApp(
        home: GroupsPage(),
      ));

      expect(find.text('Groups'), findsAtLeast(1));
    });

    testWidgets('Open SchedulePage', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(),
      ));

      expect(find.text('Schedule'), findsAtLeast(1));
    });
  });

  group('Redirect to pages', () {
    testWidgets('Open MeetingsPage, redirects to SchedulePage and back', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(key: UniqueKey()),
      ));

      final schedule = find.byKey(scheduleNavigationButtonKey);
      await tester.tap(schedule);
      await tester.pumpAndSettle();

      expect(find.text('Schedule'), findsAtLeast(1));

      final meetings = find.byKey(meetingsNavigationButtonKey);
      await tester.tap(meetings);
      await tester.pumpAndSettle();

      expect(find.text('Meetings'), findsAtLeast(1));
    });

    testWidgets('Open MeetingsPage, redirects to GroupsPage and back', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(key: UniqueKey()),
      ));

      final groups = find.byKey(groupsNavigationButtonKey);
      await tester.tap(groups);
      await tester.pumpAndSettle();

      expect(find.text('Groups'), findsAtLeast(1));

      final meetings = find.byKey(meetingsNavigationButtonKey);
      await tester.tap(meetings);
      await tester.pumpAndSettle();

      expect(find.text('Meetings'), findsAtLeast(1));
    });

    testWidgets('Open GroupsPage, redirects to SchedulePage and back', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(key: UniqueKey()),
      ));

      await tester.tap(find.byKey(groupsNavigationButtonKey));
      await tester.pumpAndSettle();

      final schedule = find.byKey(scheduleNavigationButtonKey);
      await tester.tap(schedule);
      await tester.pumpAndSettle();

      expect(find.text('Schedule'), findsAtLeast(1));

      final groups = find.byKey(groupsNavigationButtonKey);
      await tester.tap(groups);
      await tester.pumpAndSettle();

      expect(find.text('Groups'), findsAtLeast(1));
    });

    testWidgets('Open SchedulePage, redirects to GroupsPage and back', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(key: UniqueKey()),
      ));

      await tester.tap(find.byKey(groupsNavigationButtonKey));
      await tester.pumpAndSettle();

      final groups = find.byKey(groupsNavigationButtonKey);
      await tester.tap(groups);
      await tester.pumpAndSettle();

      expect(find.text('Groups'), findsAtLeast(1));

      final schedule = find.byKey(scheduleNavigationButtonKey);
      await tester.tap(schedule);
      await tester.pumpAndSettle();

      expect(find.text('Schedule'), findsAtLeast(1));
    });
  });
}
