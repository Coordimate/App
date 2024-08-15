import 'dart:io';

import 'package:coordimate/app_state.dart';
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/controllers/group_controller.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/pages/login_page.dart';
import 'package:coordimate/pages/register_page.dart';
import 'package:coordimate/pages/groups_page.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'groups_page_widget_test.mocks.dart';
import 'package:coordimate/models/groups.dart';
import 'helpers/set_appstate.dart';
import 'helpers/when.dart';
import 'helpers/client/groups.dart';

@GenerateMocks(
    [http.Client, FlutterSecureStorage, SharedPreferences, FirebaseMessaging])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final firebase = MockFirebaseMessaging();
  final client = MockClient();
  final storage = MockFlutterSecureStorage();
  final sharedPrefs = MockSharedPreferences();

  setAppState(client, storage, sharedPrefs, firebase);
  whenStatements(client, storage, sharedPrefs, firebase);

  // testWidgets('GroupsPage has create button when no groups loaded',
  //     (tester) async {
  //   whenGroupsNone(client);
  //   await tester.pumpWidget(const MaterialApp(
  //     home: GroupsPage(),
  //   ));
  //   expect(find.text('Groups'), findsOneWidget);
  //   expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);
  // });

  // testWidgets(
  //     'GroupsPage has create button when one group loaded and group card is displayed properly',
  //     (tester) async {
  //   await tester.pumpWidget(const MaterialApp(
  //     home: GroupsPage(),
  //   ));
  //   await tester.runAsync(() async {
  //     whenGroupsOne(client);
  //   });
  //   await tester.pumpAndSettle();
  //   expect(find.text('Groups'), findsOneWidget);
  //   expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);
  //   expect(find.byKey(groupCardKey), findsOneWidget);
  //   expect(find.byKey(groupCardDescriptionKey), findsOneWidget);
  //   expect(find.byKey(groupCardNameKey), findsOneWidget);
  // });

  // testWidgets('GroupsPage presses create button and scans alertdialogue',
  //     (tester) async {
  //   whenGroupsNone(client);
  //   await tester.pumpWidget(const MaterialApp(
  //     home: GroupsPage(),
  //   ));
  //   final button = find.byIcon(Icons.add_circle_outline_rounded);
  //   expect(button, findsOneWidget);

  //   await tester.runAsync(() async {
  //     await tester.tap(button);
  //   });

  //   await tester.pumpAndSettle();
  //   expect(find.byKey(createGroupKey), findsOneWidget);
  //   expect(find.text('Name'), findsOneWidget);
  //   expect(find.text('Description'), findsOneWidget);
  // });

  // testWidgets('GroupsPage presses create button and scans alertdialogue',
  //     (tester) async {
  //   whenGroupsOne(client);
  //   await tester.pumpWidget(const MaterialApp(
  //     home: GroupsPage(),
  //   ));
  //   final button = find.byIcon(Icons.add_circle_outline_rounded);
  //   expect(button, findsOneWidget);
  // });

  testWidgets('test2', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: GroupsPage(),
    ));
    await tester.runAsync(() async {
      whenGroupsOne(client);
    });
    await tester.pumpAndSettle();
    expect(find.text('Groups'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);
    expect(find.byKey(groupCardKey), findsOneWidget);
    expect(find.byKey(groupCardDescriptionKey), findsOneWidget);
    expect(find.byKey(groupCardNameKey), findsOneWidget);
  });
}
