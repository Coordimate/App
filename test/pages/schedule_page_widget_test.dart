import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/create_meeting_dialog.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/models/time_slot.dart';
import 'package:coordimate/models/user.dart';
import 'package:coordimate/pages/personal_info_page.dart';
import 'package:coordimate/pages/schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/client/data_provider.dart';
import '../test.mocks.dart';
import 'package:http/http.dart' as http;
import 'package:coordimate/widget_keys.dart';
import 'package:mockito/mockito.dart';

void main() {
  late MockAuthorizationController mockAuthController;
  late MockScheduleController mockScheduleController;
  late MockClient mockClient;

  const mockUserId = '12345';

  setUp(() {
    mockAuthController = MockAuthorizationController();
    mockScheduleController = MockScheduleController();
    mockClient = MockClient();

    AppState.authController = mockAuthController;
    AppState.scheduleController = mockScheduleController;
    AppState.client = mockClient;
    AppState.testMode = true;

    when(mockScheduleController.pageTitle).thenAnswer((_) => 'Schedule');
    when(mockScheduleController.isModifiable).thenAnswer((_) => true);
    when(mockScheduleController.canCreateMeeting).thenAnswer((_) => false);
    when(mockScheduleController.ownerId).thenAnswer((_) => mockUserId);
    when(mockScheduleController.setScheduleParams(any, any, any, any))
        .thenAnswer((_) async {});
    when(mockClient.get(
      Uri.parse('$apiUrl/share_schedule'),
      headers: anyNamed('headers'),
    )).thenAnswer(
        (_) async => http.Response('{"schedule_link": "mock_link"}', 200));
  });

  group('Schedule page picker: group, personal, on other user', () {
    testWidgets("Personal schedule", (WidgetTester tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer((_) async => []);

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(),
      ));

      await tester.pumpAndSettle();

      verify(mockScheduleController.setScheduleParams(
              '$apiUrl/time_slots', 'Schedule', true, false))
          .called(1);
      expect(find.byType(FloatingActionButton), findsOne);
    });

    testWidgets("Group schedule", (WidgetTester tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer((_) async => []);

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(
            isGroupSchedule: true, ownerId: '123', ownerName: 'Friends'),
      ));

      await tester.pumpAndSettle();

      verify(mockScheduleController.setScheduleParams(
              '$apiUrl/groups/123/time_slots', 'Friends', false, true))
          .called(1);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets("Other user schedule", (WidgetTester tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer((_) async => []);

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(ownerId: '54321', ownerName: 'Alice'),
      ));

      await tester.pumpAndSettle();

      verify(mockScheduleController.setScheduleParams(
              '$apiUrl/users/54321/time_slots', 'Alice', false, false))
          .called(1);
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });

  group('Share schedule button', () {
    testWidgets("Share button error fetching a link throws", (tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer((_) async => []);
      when(mockClient.get(Uri.parse("$apiUrl/share_schedule"),
              headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('http://mock_link', 400));

      const schedulePage = SchedulePage();

      await tester.pumpWidget(const MaterialApp(
        home: schedulePage,
      ));

      final shareButton = find.byType(FloatingActionButton);
      expect(shareButton, findsOne);

      expect(schedulePage.shareSchedule(), throwsException);
    });
  });

  testWidgets('Settings button opens the personal page',
      (WidgetTester tester) async {
    when(mockScheduleController.getTimeSlots()).thenAnswer((_) async => []);
    when(mockClient.get(Uri.parse("$apiUrl/share_schedule"),
            headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('http://mock_link', 400));

    const schedulePage = SchedulePage();

    await tester.pumpWidget(const MaterialApp(
      home: schedulePage,
    ));

    final settingsButton = find.byIcon(Icons.settings_outlined);
    expect(settingsButton, findsOne);

    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    expect(find.byType(PersonalPage), findsOne);
  });

  group('Schedule Grid', () {
    testWidgets('displays schedule grid', (WidgetTester tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer((_) async => []);

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(ScheduleGrid), findsExactly(1));
      expect(find.byType(TimeColumn), findsExactly(1));
      expect(find.byType(DayColumn), findsExactly(7));
    });
  });

  group('Day column', () {
    test('For hourHeight <= 30, fraction is 1', () {
      final dayColumn = DayColumn(
          timeSlots: const [], day: 0, refresh: () => {}, hourHeight: 15);
      expect(dayColumn.roundToFraction(30), 30);
    });

    test('For hourHeight (30, 50], fraction is 1', () {
      final dayColumn = DayColumn(
          timeSlots: const [], day: 0, refresh: () => {}, hourHeight: 40);
      expect(dayColumn.roundToFraction(60), 60);
    });

    testWidgets('Creates time slot on tap', (tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer((_) async => []);
      when(mockScheduleController.createTimeSlot(any, any, any))
          .thenAnswer((_) async {});

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(),
      ));

      final dayColumn = find.byType(DayColumn).first;
      await tester.tap(dayColumn);
      await tester.pumpAndSettle();
      verify(mockScheduleController.createTimeSlot(any, any, any)).called(1);
    });

    testWidgets('Creates meeting on tap in GroupSchedule', (tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer((_) async => []);
      when(mockScheduleController.createTimeSlot(any, any, any))
          .thenAnswer((_) async {});
      when(mockScheduleController.isModifiable).thenAnswer((_) => false);
      when(mockScheduleController.canCreateMeeting).thenAnswer((_) => true);

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(isGroupSchedule: true, ownerId: '123'),
      ));

      final dayColumn = find.byType(DayColumn).first;
      await tester.tap(dayColumn);
      await tester.pumpAndSettle();
      verifyNever(mockScheduleController.createTimeSlot(any, any, any));
      expect(find.byType(CreateMeetingDialog), findsOne);
    });

    testWidgets('Crates time slot on long press and drag', (tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer((_) async => []);
      when(mockScheduleController.createTimeSlot(any, any, any))
          .thenAnswer((_) async {});

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(),
      ));

      final dayColumn = find.byType(DayColumn).at(3);
      final newTimeSlotFinder = find.byType(NewTimeSlot).at(3);
      final newTimeSlot = (tester.state(newTimeSlotFinder) as NewTimeSlotState);

      final oldStart = newTimeSlot.start;
      final oldHeight = newTimeSlot.start;

      final Offset firstLocation = tester.getCenter(dayColumn);
      final TestGesture gesture =
          await tester.startGesture(firstLocation, pointer: 7);
      await tester.pump(const Duration(milliseconds: 800));

      expect(newTimeSlot.start != oldStart, true);

      final Offset secondLocation = tester.getBottomLeft(dayColumn);
      await gesture.moveTo(secondLocation);
      await tester.pump();

      expect(newTimeSlot.height > oldHeight, true);

      await gesture.up();
      await tester.pumpAndSettle();
      verify(mockScheduleController.createTimeSlot(any, any, any)).called(1);

      // expect(newTimeSlot.top, 0);
      // expect(newTimeSlot.height, 0);
    });

    testWidgets('Displays TimeSlotWidgets', (tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer((_) async => [
            TimeSlot(id: '1', day: 1, isMeeting: false, length: 2, start: 2),
            TimeSlot(id: '2', day: 2, isMeeting: false, length: 2, start: 4)
          ]);

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TimeSlotWidget), findsExactly(2));
    });
  });
}
