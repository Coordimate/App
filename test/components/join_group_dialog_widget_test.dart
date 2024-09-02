import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/pages/group_details_page.dart';
import 'package:coordimate/components/join_group_dialog.dart';
import '../helpers/client/data_provider.dart';
import '../test.mocks.dart';

void main() {
  late MockGroupController mockGroupController;

  setUp(() {
    mockGroupController = MockGroupController();

    AppState.groupController = mockGroupController;
    AppState.testMode = true;
  });

  testWidgets('renders JoinGroupDialog correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JoinGroupDialog(
            groupId: DataProvider.groupID1,
            groupName: DataProvider.groupName1,
            key: null,
          ),
        ),
      ),
    );

    expect(find.text(DataProvider.groupName1), findsOneWidget);
    expect(find.text('You were invited to join the group!'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
  });

  testWidgets('Reject button closes the dialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JoinGroupDialog(
            groupId: DataProvider.groupID1,
            groupName: DataProvider.groupName1,
            key: null,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();

    expect(find.byType(JoinGroupDialog), findsNothing);
  });

  testWidgets('Accept button performs correct API calls and navigation',
      (WidgetTester tester) async {
    when(mockGroupController.joinGroup(DataProvider.groupID1)).thenAnswer(
        (_) async =>
            Group(id: DataProvider.groupID1, name: DataProvider.groupName1));
    when(mockGroupController.fetchPoll(DataProvider.groupID1))
        .thenAnswer((_) async => null);
    when(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .thenAnswer((_) async => []);
    when(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JoinGroupDialog(
            groupId: DataProvider.groupID1,
            groupName: DataProvider.groupName1,
            key: null,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(find.byType(GroupDetailsPage), findsOneWidget);

    verify(mockGroupController.joinGroup(DataProvider.groupID1)).called(1);
    verify(mockGroupController.fetchPoll(DataProvider.groupID1)).called(1);
    verify(mockGroupController.fetchGroupMeetings(DataProvider.groupID1))
        .called(1);
    verify(mockGroupController.fetchGroupUsers(DataProvider.groupID1))
        .called(1);
  });
}
