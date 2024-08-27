// this will be deleted later, its only purpose is to paste the tests one by one so we can see how they run on a virtual device
//test_ont_simulator

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

  testWidgets(
      'test7: alertdialogue from create button has fields that can be typed in while respecting the character-limit',
      (tester) async {
    whenGroupsNone(client);
    whenCreateGroup(client);
    await tester.pumpWidget(const MaterialApp(
      home: GroupsPage(),
    ));

    final button = find.byIcon(Icons.add_circle_outline_rounded);
    expect(button, findsExactly(1));

    await tester.runAsync(() async {
      await tester.tap(button);
    });

    await tester.pumpAndSettle();

    final nameField = find.byKey(groupCreationNameFieldKey);
    final descrField = find.byKey(groupCreationDescriptionFieldKey);
    final createGroup = find.byKey(createGroupKey);

    expect(createGroup, findsExactly(1));
    expect(find.text('Name'), findsExactly(1));
    expect(nameField, findsExactly(1));
    expect(find.text('Description'), findsExactly(1));
    expect(descrField, findsExactly(1));

    final gName = DataProvider.getGroupName1();
    final gDescr = DataProvider.getGroupDescr1();

    await tester.enterText(nameField, gName);
    await tester.enterText(descrField, gDescr);
    await tester.pump();

    await tester.runAsync(() async {
      await tester.tap(createGroup);
    });

    await tester.pumpAndSettle();

    // expect(find.byKey(groupCardKey), findsExactly(1));
    // expect(find.byKey(groupCardDescriptionKey), findsExactly(1));
    // expect(find.text(gDescr), findsExactly(1));
    // expect(find.byKey(groupCardNameKey), findsExactly(1));
    // expect(find.text(gName), findsExactly(1));
//    expect(find.byKey(groupCardDescriptionOverflowKey), findsExactly(1));
//    expect(find.byKey(groupCardNameOverflowKey), findsExactly(1));
  });
}
