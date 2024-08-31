import 'package:coordimate/components/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:coordimate/components/group_poll_card.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/models/groups.dart';
import '../helpers/set_appstate.dart';
import '../helpers/when.dart';
import '../test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final firebase = MockFirebaseMessaging();
  final client = MockClient();
  final storage = MockFlutterSecureStorage();
  final sharedPrefs = MockSharedPreferences();

  setAppState(client, storage, sharedPrefs, firebase);
  whenStatements(client, storage, sharedPrefs, firebase);

  MockGroupController mockGroupController;
  mockGroupController = MockGroupController();
  AppState.groupController = mockGroupController;
  AppState.authController.userId = '12345';
  AppState.testMode = true;

  group('GroupPollCard', () {
    testWidgets('should navigate to CreateGroupPollPage when tapped', (WidgetTester tester) async {
      const String testGroupId = 'testGroupId';
      when(mockGroupController.fetchPoll(testGroupId)).thenAnswer((_) async => null);
      await tester.pumpWidget(const MaterialApp(home: GroupPollCard(groupId: testGroupId, initialPoll: null, fontSize: 16.0, isAdmin: true)));

      // Tap the Create Group Poll button
      await tester.pumpAndSettle();
      final createPollFinder = find.text('Create Group Poll');
      await tester.tap(createPollFinder);
      await tester.pumpAndSettle();

      // Verify if CreateGroupPollPage is pushed
      expect(find.byType(CreateGroupPollPage), findsOneWidget);
    });

    testWidgets('should display active poll when available', (WidgetTester tester) async {
      // Arrange
      const String testGroupId = 'testGroupId';
      final testPoll = GroupPoll(question: 'Test Poll', options: ['Option 1', 'Option 2']);
      when(mockGroupController.fetchPoll(testGroupId)).thenAnswer((_) async => testPoll);
      await tester.pumpWidget(MaterialApp(home: GroupPollCard(groupId: testGroupId, initialPoll: testPoll, fontSize: 16.0, isAdmin: false)));

      // Act
      await tester.pump();

      // Assert
      expect(find.text('Active Group Poll'), findsOneWidget);
    });

    testWidgets('should dismiss poll and delete on swipe', (WidgetTester tester) async {
      // Arrange
      const String testGroupId = 'testGroupId';
      final testPoll = GroupPoll(question: 'Test Poll', options: ['Option 1', 'Option 2']);
      when(mockGroupController.fetchPoll(testGroupId)).thenAnswer((_) async => testPoll);

      await tester.pumpWidget(MaterialApp(home: GroupPollCard(groupId: testGroupId, initialPoll: testPoll, fontSize: 16.0, isAdmin: true)));
      await tester.pumpAndSettle();

      // Once the poll widget is dismissed, the widget will refetch the group poll
      when(mockGroupController.fetchPoll(testGroupId)).thenAnswer((_) async => null);
      await tester.drag(find.byType(Dismissible), const Offset(1500, 0));
      await tester.pumpAndSettle();

      // Assert
      verify(mockGroupController.deletePoll(testGroupId)).called(1);
      expect(find.text('Active Group Poll'), findsNothing);
    });
  });

  group('CreateGroupPollPage', () {
    testWidgets('should display question and options fields', (WidgetTester tester) async {
      const String testGroupId = 'testGroupId';
      await tester.pumpWidget(const MaterialApp(home: CreateGroupPollPage(groupId: testGroupId)));

      expect(find.byType(QuestionTextField), findsOneWidget);
      expect(find.byType(AddOptionButton), findsOneWidget);
    });

    testWidgets('should add an option when AddOptionButton is tapped', (WidgetTester tester) async {
      const String testGroupId = 'testGroupId';
      await tester.pumpWidget(const MaterialApp(home: CreateGroupPollPage(groupId: testGroupId)));

      // Initially, there should be 2 option fields
      expect(find.byType(PollTextField), findsNWidgets(2));
      await tester.tap(find.byType(AddOptionButton));
      await tester.pump();

      // After tapping, there should be 3 option fields
      expect(find.byType(PollTextField), findsNWidgets(3));
    });

    testWidgets('should call createPoll and pop when valid input is provided', (WidgetTester tester) async {
      const String testGroupId = 'testGroupId';
      await tester.pumpWidget(const MaterialApp(home: CreateGroupPollPage(groupId: testGroupId)));

      // Enter valid question and options
      await tester.enterText(find.byType(QuestionTextField), 'Test Question');
      await tester.enterText(find.byType(PollTextField).first, 'Option 1');
      await tester.enterText(find.byType(PollTextField).at(1), 'Option 2');

      // Tap the send button
      await tester.tap(find.text("Create"));
      await tester.pump();

      // Verify createPoll was called
      verify(mockGroupController.createPoll(testGroupId, any)).called(1);
    });
  });

  group('VoteGroupPollPage', () {
    late GroupPoll poll;
    poll = GroupPoll(question: 'Test Poll', options: ['Option 1', 'Option 2']);

    testWidgets('should display poll question and options', (WidgetTester tester) async {
      const String testGroupId = 'testGroupId';
      await tester.pumpWidget(MaterialApp(home: VoteGroupPollPage(groupId: testGroupId, poll: poll, memberAvatars: const {'12345': Avatar(size: 30, userId: '12345')})));

      expect(find.text('Test Poll'), findsOneWidget);
      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
    });

    testWidgets('should place a vote and update vote count', (WidgetTester tester) async {
      AppState.authController.userId = '12345';
      const String testGroupId = 'testGroupId';
      await tester.pumpWidget(MaterialApp(home: VoteGroupPollPage(groupId: testGroupId, poll: poll, memberAvatars: const {'12345': Avatar(size: 30, userId: '12345')})));

      // Tap on the first option
      await tester.tap(find.text('Option 1'));
      await tester.pump();

      // Verify that placeVote was called
      verify(mockGroupController.voteOnPoll(testGroupId, 0)).called(1);
    });
  });

}
