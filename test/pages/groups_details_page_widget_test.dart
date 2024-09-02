import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/create_meeting_dialog.dart';
import 'package:coordimate/components/meeting_tiles.dart';
import 'package:coordimate/pages/group_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/client/data_provider.dart';
import '../test.mocks.dart';
import '../helpers/client/groups.dart' as groups;
import 'package:coordimate/widget_keys.dart';
import 'package:mockito/mockito.dart';

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

  testWidgets(
      'test1: check if all the elements are present inside the groupsdetailspage from admin POV',
      (tester) async {
    when(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.userCard1, groups.userCard2]);
    when(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.meetingin2Days]);
    when(mockGroupController.fetchPoll(DataProvider.groupID1))
        .thenAnswer((_) async => null);
    AppState.authController.userId = DataProvider.userAdmin;

    await tester.pumpWidget(MaterialApp(
      home: GroupDetailsPage(group: groups.group1),
    ));
    await tester.pumpAndSettle();

    final memberCard = find.byKey(groupMemberKey);
    final pollpanel = find.byKey(pollPanelKey);

    expect(find.byKey(appBarIconButtonKey), findsExactly(1));
    expect(find.byKey(inviteButtonKey), findsExactly(1));
    expect(find.byKey(avatarKey), findsExactly(1));
    expect(find.byKey(createMeetingButtonKey), findsExactly(1));
    expect(find.byKey(groupNameFieldKey), findsExactly(1));
    expect(find.byKey(groupMemberCountKey), findsExactly(1));
    expect(find.byKey(linkPlaceholderFieldKey), findsExactly(1));
    expect(find.byKey(copyButtonKey), findsExactly(1));
    expect(find.byKey(shareButtonKey), findsExactly(1));
    expect(find.byKey(groupDescriptionFieldKey), findsExactly(1));
    expect(pollpanel, findsExactly(1));
    expect(
        find.descendant(
            of: pollpanel, matching: find.text('Create Group Poll')),
        findsExactly(1));
    expect(find.byKey(groupScheduleButtonKey), findsExactly(1));
    expect(find.byKey(groupMembersListKey), findsExactly(1));
    expect(memberCard, findsExactly(2));
    expect(find.byKey(groupChatButtonKey), findsExactly(1));
    expect(find.byKey(deleteGroupButtonKey), findsExactly(1));
    expect(find.byIcon(Icons.edit), findsExactly(2));
    expect(find.byIcon(Icons.close), findsExactly(1));
    expect(find.descendant(of: memberCard, matching: find.text('admin')),
        findsExactly(1));
  });

  testWidgets('test2: check for active poll and empty group description',
      (tester) async {
    when(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.userCard1, groups.userCard2]);
    when(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.meetingin2Days]);
    when(mockGroupController.fetchPoll(DataProvider.groupID1))
        .thenAnswer((_) async => groups.pollData);
    AppState.authController.userId = DataProvider.userAdmin;

    await tester.pumpWidget(MaterialApp(
      home: GroupDetailsPage(group: groups.group2),
    ));
    await tester.pumpAndSettle();

    final pollpanel = find.byKey(pollPanelKey);

    expect(find.byKey(noGroupDescriptionFieldKey), findsExactly(1));
    expect(pollpanel, findsExactly(1));
    expect(
        find.descendant(
            of: pollpanel, matching: find.text('Active Group Poll')),
        findsExactly(1));
  });

  testWidgets('test3: group from member POV', (tester) async {
    when(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.userCard1, groups.userCard2]);
    when(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.meetingin2Days]);
    when(mockGroupController.fetchPoll(DataProvider.groupID1))
        .thenAnswer((_) async => null);
    AppState.authController.userId = DataProvider.userID2;

    await tester.pumpWidget(MaterialApp(
      home: GroupDetailsPage(group: groups.group1),
    ));
    await tester.pumpAndSettle();

    final pollpanel = find.byKey(pollPanelKey);

    expect(pollpanel, findsExactly(1));

    expect(find.byKey(leaveGroupButtonKey), findsExactly(1));
  });

  testWidgets(
      'test4: checking meeting presence, pressing archive, checking archived meeting presence',
      (tester) async {
    when(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.userCard1, groups.userCard2]);
    when(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .thenAnswer(
            (_) async => [groups.meetingin2Days, groups.meetingArchived]);
    when(mockGroupController.fetchPoll(DataProvider.groupID1))
        .thenAnswer((_) async => null);
    AppState.authController.userId = DataProvider.userID2;

    await tester.pumpWidget(MaterialApp(
      home: GroupDetailsPage(group: groups.group1),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(groupAcceptedMeetingKey), findsExactly(1));
    final button = find.byKey(appBarIconButtonKey);
    expect(button, findsExactly(1));

    await tester.tap(button);

    await tester.pumpAndSettle();

    expect(find.byType(ArchivedMeetingTile), findsExactly(1));
  });

  testWidgets('test5: pressing invite button', (tester) async {
    when(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.userCard1, groups.userCard2]);
    when(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .thenAnswer(
            (_) async => [groups.meetingin2Days, groups.meetingArchived]);
    when(mockGroupController.fetchPoll(DataProvider.groupID1))
        .thenAnswer((_) async => null);
    when(mockGroupController.shareInviteLink(DataProvider.groupID1))
        .thenAnswer((_) async => groups.inviteLink);
    AppState.authController.userId = DataProvider.userID2;

    await tester.pumpWidget(MaterialApp(
      home: GroupDetailsPage(group: groups.group1),
    ));
    await tester.pumpAndSettle();

    final button = find.byKey(inviteButtonKey);
    expect(button, findsExactly(1));
    await tester.tap(button);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(groupNameFieldKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(groupNameFieldKey));
    await tester.pumpAndSettle();
  });

  testWidgets('test6: pressing create meeting and verify request was sent',
      (tester) async {
    when(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.userCard1, groups.userCard2]);
    when(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .thenAnswer(
            (_) async => [groups.meetingin2Days, groups.meetingArchived]);
    when(mockGroupController.fetchPoll(DataProvider.groupID1))
        .thenAnswer((_) async => null);
    when(mockMeetingController.createMeeting(any, any, any, any, any))
        .thenAnswer((_) async => Future.value());

    AppState.authController.userId = DataProvider.userID2;

    await tester.pumpWidget(MaterialApp(
      home: GroupDetailsPage(group: groups.group1),
    ));
    await tester.pumpAndSettle();

    final button = find.byKey(createMeetingButtonKey);

    expect(button, findsExactly(1));
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.byKey(createMeetingDialogTitleKey), findsExactly(1));
    await tester.enterText(
        find.byKey(createMeetingDialogTitleKey), DataProvider.meetingTitle);

    final confirmMeetingButton = find.byKey(yesButtonKey);
    final cancelMeetingButton = find.byKey(noButtonKey);
    expect(confirmMeetingButton, findsExactly(1));
    expect(cancelMeetingButton, findsExactly(1));
    await tester.tap(confirmMeetingButton);
    await tester.pumpAndSettle();
    verify(mockMeetingController.createMeeting(any, any, any, any, any))
        .called(1);

    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(cancelMeetingButton);
    await tester.pumpAndSettle();

    expect(find.byType(CreateMeetingDialog), findsNothing);
  });

  testWidgets('test7: check link placeholder copy and share buttons',
      (tester) async {
    when(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.userCard1, groups.userCard2]);
    when(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .thenAnswer(
            (_) async => [groups.meetingin2Days, groups.meetingArchived]);
    when(mockGroupController.fetchPoll(DataProvider.groupID1))
        .thenAnswer((_) async => null);
    when(mockGroupController.updateGroupMeetingLink(
            DataProvider.groupID1, DataProvider.groupMeetingLink))
        .thenAnswer((_) async => Future.value());
    final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    AppState.authController.userId = DataProvider.userID2;

    await tester.pumpWidget(MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: GroupDetailsPage(group: groups.group1),
    ));
    await tester.pumpAndSettle();

    final copy = find.byKey(copyButtonKey);
    final share = find.byKey(shareButtonKey);

    expect(copy, findsExactly(1));
    expect(share, findsExactly(1));

    await tester.enterText(
        find.byKey(linkPlaceholderFieldKey), DataProvider.groupMeetingLink);
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);

    await tester.enterText(
        find.byKey(linkPlaceholderFieldKey), DataProvider.groupMeetingLink2);
    await tester.pumpAndSettle();

    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    verify(mockGroupController.updateGroupMeetingLink(
      any,
      any,
    )).called(2);

    await tester.tap(copy);
    await tester.pump();
    expect(find.byType(SnackBar), findsExactly(1));

    await tester.tap(share);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(groupNameFieldKey));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'test8: check and then edit group name and group description and check that they updated again',
      (tester) async {
    when(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.userCard1, groups.userCard2]);
    when(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .thenAnswer(
            (_) async => [groups.meetingin2Days, groups.meetingArchived]);
    when(mockGroupController.fetchPoll(DataProvider.groupID1))
        .thenAnswer((_) async => null);
    when(mockGroupController.updateGroupName(
            DataProvider.groupID1, DataProvider.newgroupname))
        .thenAnswer((_) async => Future.value());
    when(mockGroupController.updateGroupDescription(
            DataProvider.groupID1, DataProvider.newgroupdescr))
        .thenAnswer((_) async => Future.value());
    AppState.authController.userId = DataProvider.userID2;
    await tester.pumpWidget(MaterialApp(
      home: GroupDetailsPage(group: groups.group1),
    ));
    await tester.pumpAndSettle();

    final nameEditIcon = find.descendant(
        of: find.byKey(groupNameFieldKey), matching: find.byIcon(Icons.edit));
    final descrEditIcon = find.descendant(
        of: find.byKey(groupDescriptionFieldKey),
        matching: find.byIcon(Icons.edit));
    final check = find.byIcon(Icons.check);
    final groupnamefield = find.byKey(groupNameFieldKey);
    final groupdescrfield = find.byKey(groupDescriptionFieldKey);
    final newgroupname = DataProvider.newgroupname;
    final newgroupdescr = DataProvider.newgroupdescr;
    expect(
        find.descendant(
            of: groupnamefield, matching: find.text(groups.group1.name)),
        findsExactly(2));

    expect(
        find.descendant(
            of: groupdescrfield,
            matching: find.text(groups.group1.description)),
        findsExactly(2));

    expect(nameEditIcon, findsExactly(1));
    expect(descrEditIcon, findsExactly(1));

    await tester.tap(nameEditIcon);
    await tester.enterText(groupnamefield, newgroupname);
    await tester.pumpAndSettle();
    expect(check, findsExactly(1));
    await tester.tap(check);

    expect(
        find.descendant(of: groupnamefield, matching: find.text(newgroupname)),
        findsExactly(2));

    await tester.tap(descrEditIcon);
    await tester.enterText(groupdescrfield, newgroupdescr);
    await tester.pumpAndSettle();
    expect(check, findsExactly(1));
    await tester.tap(check);

    expect(
        find.descendant(
            of: groupdescrfield, matching: find.text(newgroupdescr)),
        findsExactly(2));

    verify(mockGroupController.updateGroupName(
      any,
      any,
    )).called(1);
    verify(mockGroupController.updateGroupDescription(
      any,
      any,
    )).called(1);
  });

  testWidgets('test9: tap active poll and member leaves group', (tester) async {
    when(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.userCard1, groups.userCard2]);
    when(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.meetingin2Days]);
    when(mockGroupController.fetchPoll(DataProvider.groupID1))
        .thenAnswer((_) async => groups.pollData);
    when(mockGroupController.voteOnPoll(DataProvider.groupID1, 1))
        .thenAnswer((_) async => Future.value());
    AppState.authController.userId = DataProvider.userID2;

    await tester.pumpWidget(MaterialApp(
      home: GroupDetailsPage(group: groups.group1),
    ));
    await tester.pumpAndSettle();
    final pollpanel = find.byKey(pollPanelKey);
    expect(pollpanel, findsExactly(1));

    final pollButton = find.descendant(
        of: pollpanel, matching: find.text('Active Group Poll'));

    await tester.tap(pollButton);
    await tester.pumpAndSettle();

    final option = find.text('option1');
    expect(option, findsExactly(1));
    await tester.tap(option);

    final backButtonFinder = find.byTooltip('Back');
    await tester.tap(backButtonFinder);
    await tester.pumpAndSettle();

    verify(mockGroupController.voteOnPoll(any, any)).called(1);
  });

  testWidgets('test10: member leaves group', (tester) async {
    when(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.userCard2]);
    when(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .thenAnswer((_) async => []);
    when(mockGroupController.fetchPoll(DataProvider.groupID1))
        .thenAnswer((_) async => null);
    when(mockGroupController.leaveGroup(DataProvider.groupID1))
        .thenAnswer((_) async => Future.value());

    AppState.authController.userId = DataProvider.userID2;

    await tester.pumpWidget(MaterialApp(
      home: GroupDetailsPage(group: groups.group1),
    ));
    final leaveButton = find.byKey(leaveGroupButtonKey);

    await tester.pumpAndSettle();
    await tester.ensureVisible(leaveButton);
    expect(leaveButton, findsExactly(1));
    await tester.tap(leaveButton);
    await tester.pumpAndSettle();

    final noButton = find.byKey(noButtonKey);
    await tester.tap(noButton);
    await tester.pumpAndSettle();

    await tester.ensureVisible(leaveButton);
    expect(leaveButton, findsExactly(1));
    await tester.tap(leaveButton);
    await tester.pumpAndSettle();

    final yesbutton = find.byKey(yesButtonKey);
    expect(yesbutton, findsExactly(1));
    await tester.tap(yesbutton);
    await tester.pumpAndSettle();
    verify(mockGroupController.leaveGroup(
      any,
    )).called(1);
  });

  testWidgets('test11: admin removes user from group', (tester) async {
    when(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.userCard1, groups.userCard2]);
    when(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .thenAnswer((_) async => []);
    when(mockGroupController.fetchPoll(DataProvider.groupID1))
        .thenAnswer((_) async => null);
    when(mockGroupController.removeUser(
            DataProvider.userID2, DataProvider.groupID1))
        .thenAnswer((_) async => Future.value());

    AppState.authController.userId = DataProvider.userAdmin;

    await tester.pumpWidget(MaterialApp(
      home: GroupDetailsPage(group: groups.group1),
    ));
    await tester.pumpAndSettle();

    final removeUserButton = find.byIcon(Icons.close);
    await tester.ensureVisible(removeUserButton);
    expect(removeUserButton, findsExactly(1));
    await tester.tap(removeUserButton);
    await tester.pumpAndSettle();

    final noButton = find.byKey(noButtonKey);
    await tester.tap(noButton);
    await tester.pumpAndSettle();

    await tester.ensureVisible(removeUserButton);
    expect(removeUserButton, findsExactly(1));
    await tester.tap(removeUserButton);
    await tester.pumpAndSettle();

    final yesbutton = find.byKey(yesButtonKey);
    expect(yesbutton, findsExactly(1));
    await tester.tap(yesbutton);
    await tester.pumpAndSettle();
    verify(mockGroupController.removeUser(any, any)).called(1);
  });

  testWidgets('test12: admin deletes group', (tester) async {
    when(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.userCard1, groups.userCard2]);
    when(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .thenAnswer((_) async => []);
    when(mockGroupController.fetchPoll(DataProvider.groupID1))
        .thenAnswer((_) async => null);
    when(mockGroupController.deleteGroup(DataProvider.groupID1))
        .thenAnswer((_) async => Future.value());

    AppState.authController.userId = DataProvider.userAdmin;

    await tester.pumpWidget(MaterialApp(
      home: GroupDetailsPage(group: groups.group1),
    ));
    await tester.pumpAndSettle();

    final deleteButton = find.byKey(deleteGroupButtonKey);
    await tester.ensureVisible(deleteButton);
    expect(deleteButton, findsExactly(1));
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    final noButton = find.byKey(noButtonKey);
    await tester.tap(noButton);
    await tester.pumpAndSettle();

    await tester.ensureVisible(deleteButton);
    expect(deleteButton, findsExactly(1));
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    final yesbutton = find.byKey(yesButtonKey);
    expect(yesbutton, findsExactly(1));
    await tester.tap(yesbutton);
    await tester.pumpAndSettle();
    verify(mockGroupController.deleteGroup(
      any,
    )).called(1);
  });

  testWidgets('test13: update empty group description', (tester) async {
    when(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.userCard1, groups.userCard2]);
    when(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .thenAnswer((_) async => [groups.meetingin2Days]);
    when(mockGroupController.fetchPoll(DataProvider.groupID1))
        .thenAnswer((_) async => groups.pollData);
    when(mockGroupController.updateGroupDescription(
            DataProvider.groupID1, DataProvider.newgroupdescr))
        .thenAnswer((_) async => Future.value());
    AppState.authController.userId = DataProvider.userAdmin;

    await tester.pumpWidget(MaterialApp(
      home: GroupDetailsPage(group: groups.group2),
    ));
    await tester.pumpAndSettle();
    final groupdescrfield = find.byKey(noGroupDescriptionFieldKey);
    expect(groupdescrfield, findsExactly(1));

    final descrEditIcon =
        find.descendant(of: groupdescrfield, matching: find.byIcon(Icons.edit));
    final check = find.byIcon(Icons.check);

    final newgroupdescr = DataProvider.newgroupdescr;
    expect(
        find.descendant(
            of: groupdescrfield, matching: find.text("No Group Description")),
        findsExactly(1));

    expect(descrEditIcon, findsExactly(1));

    await tester.tap(descrEditIcon);
    await tester.enterText(groupdescrfield, newgroupdescr);
    await tester.pumpAndSettle();
    expect(check, findsExactly(1));
    await tester.tap(check);

    expect(
        find.descendant(
            of: groupdescrfield, matching: find.text(newgroupdescr)),
        findsExactly(2));
    verify(mockGroupController.updateGroupDescription(
      any,
      any,
    )).called(1);
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
