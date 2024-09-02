import 'package:coordimate/components/pop_up_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:coordimate/components/create_meeting_dialog.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/login_button.dart';
import 'package:intl/intl.dart';
import '../test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockMeetingController = MockMeetingController();
  AppState.meetingController = mockMeetingController;

  group('CreateMeetingDialog Tests', () {
    testWidgets('renders CreateMeetingDialog correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CreateMeetingDialog(groupId: 'test_group_id'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Create Meeting'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(LoginEmptyButton), findsNWidgets(3));
      expect(find.byType(TextField), findsExactly(2));
      expect(find.byType(ConfirmationButtons), findsOneWidget);
    });

    testWidgets('selects date correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CreateMeetingDialog(groupId: 'test_group_id'),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(DateFormat('EEE, MMMM d, y').format(DateTime.now().add(const Duration(minutes: 10)))));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text(DateFormat('EEE, MMMM d, y').format(DateTime.now().add(const Duration(minutes: 10)))), findsOneWidget);
    });

    testWidgets('selects time correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CreateMeetingDialog(groupId: 'test_group_id'),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(DateFormat('HH:mm').format(DateTime.now().add(const Duration(minutes: 10)))));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text(DateFormat('HH:mm').format(DateTime.now().add(const Duration(minutes: 10)))), findsOneWidget);
    });

    testWidgets('selects duration correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CreateMeetingDialog(groupId: 'test_group_id'),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1h'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('1h'), findsOneWidget);
    });

    testWidgets('validates form correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CreateMeetingDialog(groupId: 'test_group_id'),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('creates meeting correctly', (tester) async {
      when(mockMeetingController.createMeeting(any, any, any, any, any)).thenAnswer((_) async {});

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CreateMeetingDialog(groupId: 'test_group_id'),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Test Meeting');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      verify(mockMeetingController.createMeeting(any, any, any, any, any)).called(1);
    });
  });
}