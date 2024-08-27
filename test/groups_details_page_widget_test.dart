import 'package:coordimate/app_state.dart';
import 'package:coordimate/pages/groups_page.dart';
import 'package:coordimate/pages/group_details_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'groups_details_page_widget_test.mocks.dart';
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
      'test1: the group card is tappable and redirects to a mocked groupsdetailspage',
      (tester) async {
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
    expect(find.byType(GroupDetailsPage), findsOne);
  });

  testWidgets(
      'test2: check if all the elements are present inside the groupsdetailspage',
      (tester) async {
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

//    const noGroupDescriptionFieldKey = Key('noGroupDescriptionField');
//const groupAdminKey = Key('groupAdmin');
    final memberCard = find.byKey(groupMemberKey);

    expect(find.byKey(inviteButtonKey), findsExactly(1));
    expect(find.byKey(createMeetingButtonKey), findsExactly(1));
    expect(find.byKey(groupNameFieldKey), findsExactly(1));
    expect(find.byKey(groupMemberCountKey), findsExactly(1));
    expect(find.byKey(linkPlaceholderFieldKey), findsExactly(1));
    expect(find.byKey(copyButtonKey), findsExactly(1));
    expect(find.byKey(shareButtonKey), findsExactly(1));
    expect(find.byKey(groupDescriptionFieldKey), findsExactly(1));
    //expect(find.byKey(noGroupDescriptionFieldKey), findsExactly(1));
    expect(find.byKey(createGroupPollButtonKey), findsExactly(1));
    expect(find.byKey(groupScheduleButtonKey), findsExactly(1));
    expect(find.byKey(groupMembersListKey), findsExactly(1));
    expect(memberCard, findsExactly(1));
    expect(find.byKey(groupChatButtonKey), findsExactly(1));
    expect(find.byKey(deleteGroupButtonKey), findsExactly(1));
    expect(find.byIcon(Icons.edit), findsExactly(2));
    // expect(find.descendant(of: memberCard, matching: find.text('admin')),
    //     findsExactly(1));
    expect(find.text('admin'), findsExactly(1));
  });
}
