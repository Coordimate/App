// this will be deleted later, its only purpose is to paste the tests one by one so we can see how they run on a virtual device

import 'package:coordimate/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test.mocks.dart';
import 'helpers/client/groups.dart' as groups;
import 'package:coordimate/widget_keys.dart';
import 'package:coordimate/pages/group_details_page.dart';
import 'package:mockito/mockito.dart';
import 'helpers/client/data_provider.dart';

void main() {
  late MockGroupController mockGroupController;
  late MockMeetingController mockMeetingController;

  setUp(() {
    mockGroupController = MockGroupController();
    mockMeetingController = MockMeetingController();
    AppState.groupController = mockGroupController;
    AppState.meetingController = mockMeetingController;
    AppState.testMode = true;
  });

  testWidgets('test14: tap on group schedule', (tester) async {
    when(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.userCard1, groups.userCard2]);
    when(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.meetingin2Days]);
    when(mockGroupController.fetchPoll(DataProvider.groupID1))
        .thenAnswer((_) async => groups.pollData);
    AppState.authController.userId = DataProvider.userID2;

    await tester.pumpWidget(MaterialApp(
      home: GroupDetailsPage(group: groups.group1),
    ));
    await tester.pumpAndSettle();
    final button = find.text("Group Schedule");
    expect(button, findsExactly(1));
    await tester.tap(button);
    await tester.pumpAndSettle();

    final backButtonFinder = find.byTooltip('Back');
    await tester.tap(backButtonFinder);
    await tester.pumpAndSettle();

    final memberCard = find.text(DataProvider.username1);
    await tester.ensureVisible(memberCard);
    await tester.tap(memberCard);
    await tester.pumpAndSettle();
  });
}
