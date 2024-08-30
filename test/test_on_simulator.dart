// this will be deleted later, its only purpose is to paste the tests one by one so we can see how they run on a virtual device

import 'package:coordimate/app_state.dart';
import 'package:coordimate/pages/groups_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test.mocks.dart';
import 'helpers/set_appstate.dart';
import 'helpers/when.dart';
import 'helpers/client/groups.dart';
import 'package:coordimate/widget_keys.dart';

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
