//groups_page_widget_test

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

  testWidgets('test1: groups page has create button when no groups loaded',
      (tester) async {
    whenGroupsNone(client);
    await tester.pumpWidget(const MaterialApp(
      home: GroupsPage(),
    ));
    expect(find.text('Groups'), findsExactly(1));
    expect(find.byIcon(Icons.add_circle_outline_rounded), findsExactly(1));
  });

  testWidgets(
      'test2: groups page has groups card with name and description displayed when one group loaded',
      (tester) async {
    AppState.testMode = true;
    whenGroupsOne(client);

    await tester.pumpWidget(const MaterialApp(
      home: GroupsPage(),
    ));

    await tester.pumpAndSettle();
    expect(find.text('Groups'), findsExactly(1));
    expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);
    expect(find.byKey(groupCardKey), findsExactly(1));
    expect(find.byKey(groupCardDescriptionKey), findsExactly(1));
    expect(find.byKey(groupCardNameKey), findsExactly(1));
  });

  testWidgets(
      'test3: groups page presses create button and an alertdialogue window appears, containing name and description text fields and finalization create group button',
      (tester) async {
    whenGroupsNone(client);
    await tester.pumpWidget(const MaterialApp(
      home: GroupsPage(),
    ));
    final button = find.byIcon(Icons.add_circle_outline_rounded);
    expect(button, findsExactly(1));

    await tester.runAsync(() async {
      await tester.tap(button);
    });

    await tester.pumpAndSettle();
    expect(find.byKey(createGroupKey), findsExactly(1));
    expect(find.text('Name'), findsExactly(1));
    expect(find.byKey(groupCreationNameFieldKey), findsExactly(1));
    expect(find.text('Description'), findsExactly(1));
    expect(find.byKey(groupCreationDescriptionFieldKey), findsExactly(1));
  });

  testWidgets(
      'test4: groups page has groups card with name and description displayed when two groups loaded',
      (tester) async {
    AppState.testMode = true;
    whenGroupsTwo(client);
    await tester.pumpWidget(const MaterialApp(
      home: GroupsPage(),
    ));

    await tester.pumpAndSettle();
    expect(find.text('Groups'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);

    expect(find.byKey(groupCardKey), findsExactly(2));
    expect(find.byKey(groupCardDescriptionKey), findsExactly(2));
    expect(find.text(DataProvider.getGroupDescr1()), findsExactly(1));
    expect(find.text(DataProvider.getGroupDescr2()), findsExactly(1));
    expect(find.byKey(groupCardNameKey), findsExactly(2));
    expect(find.text(DataProvider.getGroupName1()), findsExactly(1));
    expect(find.text(DataProvider.getGroupName2()), findsExactly(1));
    // print(DataProvider.getGroupName1() +
    //     DataProvider.getGroupName2() +
    //     DataProvider.getGroupDescr1() +
    //     DataProvider.getGroupDescr2());
  });

// this is an alternative for using ellipsestext, that doesnt confirm if the
// text has an ellipses or has been truncated for certain, but rather compares the
// original text size compared to the rendered one

  // testWidgets(
  //     'test5: groups page has a group card with a long group description',
  //     (tester) async {
  //   AppState.testMode = true;
  //   whenGroupsLongOne(client);
  //   await tester.pumpWidget(const MaterialApp(
  //     home: GroupsPage(),
  //   ));

  //   await tester.pumpAndSettle();
  //   expect(find.text('Groups'), findsOneWidget);
  //   expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);

  //   expect(find.byKey(groupCardKey), findsExactly(1));
  //   expect(find.byKey(groupCardDescriptionKey), findsExactly(1));
  //   expect(find.text(DataProvider.getLongGroupDescr()), findsExactly(1));
  //   expect(find.byKey(groupCardNameKey), findsExactly(1));
  //   expect(find.text(DataProvider.getGroupName1()), findsExactly(1));

  //   final textFinder = find.byKey(groupCardDescriptionKey);
  //   final Text textWidget = tester.widget(textFinder);

  //   final TextPainter textPainter = TextPainter(
  //     text: TextSpan(text: textWidget.data, style: textWidget.style),
  //     maxLines: 1,
  //     textDirection: TextDirection.ltr,
  //     ellipsis: '!',
  //   );
  //   print(textPainter.text);
  //   textPainter.layout(maxWidth: tester.getSize(textFinder).width);

  //   expect(textPainter.didExceedMaxLines, isTrue,
  //       reason: "Text should be truncated with ellipses");
  // });

  testWidgets(
      'test5: groups page has a group card with a long group description that is truncated',
      (tester) async {
    AppState.testMode = true;
    whenGroupsLongOne(client);
    await tester.pumpWidget(const MaterialApp(
      home: GroupsPage(),
    ));

    await tester.pumpAndSettle();
    expect(find.text('Groups'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);

    expect(find.byKey(groupCardKey), findsExactly(1));
    expect(find.byKey(groupCardDescriptionKey), findsExactly(1));
    expect(find.text(DataProvider.getLongGroupDescr()), findsExactly(1));
    expect(find.byKey(groupCardNameKey), findsExactly(1));
    expect(find.text(DataProvider.getGroupName1()), findsExactly(1));
    expect(find.byKey(groupCardDescriptionOverflowKey), findsExactly(1));
  });

  testWidgets(
      'test6: groups page has a group card with a long group name and long description, both are truncated',
      (tester) async {
    AppState.testMode = true;
    whenGroupsLongNameAndDescr(client);
    await tester.pumpWidget(const MaterialApp(
      home: GroupsPage(),
    ));

    await tester.pumpAndSettle();
    expect(find.text('Groups'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);

    expect(find.byKey(groupCardKey), findsExactly(1));
    expect(find.byKey(groupCardDescriptionKey), findsExactly(1));
    expect(find.text(DataProvider.getLongGroupDescr()), findsExactly(1));
    expect(find.byKey(groupCardNameKey), findsExactly(1));
    expect(find.text(DataProvider.getLongGroupName()), findsExactly(1));
    expect(find.byKey(groupCardDescriptionOverflowKey), findsExactly(1));
    expect(find.byKey(groupCardNameOverflowKey), findsExactly(1));
  });

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
