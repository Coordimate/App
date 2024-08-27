// this will be deleted later, its only purpose is to paste the tests one by one so we can see how they run on a virtual device

import 'package:coordimate/app_state.dart';
import 'package:coordimate/pages/groups_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'groups_page_widget_test.mocks.dart';
import 'helpers/set_appstate.dart';
import 'helpers/when.dart';
import 'helpers/client/groups.dart';
import 'helpers/client/data_provider.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:mockito/mockito.dart';
import 'package:coordimate/keys.dart';

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

  testWidgets('test1', (tester) async {
    AppState.testMode = true;
    whenGroupsOne(client);
    whenGroupsDetails(client);
    whenGroupsMeetings(client);
    await tester.pumpWidget(const MaterialApp(
      home: GroupsPage(),
    ));
    await tester.pumpAndSettle();
    final button = find.byKey(groupCardKey);
    expect(button, findsExactly(1));

    await tester.runAsync(() async {
      await tester.tap(button);
    });

    await tester.pumpAndSettle();
  });
}
