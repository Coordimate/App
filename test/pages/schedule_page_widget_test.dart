import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/create_meeting_dialog.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/models/time_slot.dart';
import 'package:coordimate/pages/personal_info_page.dart';
import 'package:coordimate/pages/schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
      when(mockScheduleController.getTimeSlots()).thenAnswer(
          (_) async => [TimeSlot(id: '1', day: 1, start: 2, length: 2)]);
      when(mockScheduleController.isModifiable).thenAnswer((_) => true);
      when(mockScheduleController.canCreateMeeting).thenAnswer((_) => false);

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(),
      ));

      await tester.pumpAndSettle();

      verify(mockScheduleController.setScheduleParams(
              '$apiUrl/time_slots', 'Schedule', true, false))
          .called(1);
      expect(find.byType(FloatingActionButton), findsOne);

      expect(find.byType(TimeSlotWidget), findsOne);
      await tester.tap(find.byType(TimeSlotWidget));
      await tester.pumpAndSettle();
      expect(find.byType(TimePicker), findsOne);
    });

    testWidgets("Group schedule", (WidgetTester tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer(
          (_) async => [TimeSlot(id: '1', day: 1, start: 2, length: 2)]);
      when(mockScheduleController.isModifiable).thenAnswer((_) => false);
      when(mockScheduleController.canCreateMeeting).thenAnswer((_) => true);

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(
            isGroupSchedule: true, ownerId: '123', ownerName: 'Friends'),
      ));

      await tester.pumpAndSettle();

      verify(mockScheduleController.setScheduleParams(
              '$apiUrl/groups/123/time_slots', 'Friends', false, true))
          .called(1);
      expect(find.byType(FloatingActionButton), findsNothing);

      expect(find.byType(TimeSlotWidget), findsOne);
      await tester.tap(find.byType(TimeSlotWidget));
      await tester.pumpAndSettle();
      expect(find.byType(TimePicker), findsNothing);
    });

    testWidgets("Other user schedule", (WidgetTester tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer(
          (_) async => [TimeSlot(id: '1', day: 1, start: 2, length: 2)]);
      when(mockScheduleController.isModifiable).thenAnswer((_) => false);
      when(mockScheduleController.canCreateMeeting).thenAnswer((_) => false);

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(ownerId: '54321', ownerName: 'Alice'),
      ));

      await tester.pumpAndSettle();

      verify(mockScheduleController.setScheduleParams(
              '$apiUrl/users/54321/time_slots', 'Alice', false, false))
          .called(1);
      expect(find.byType(FloatingActionButton), findsNothing);

      expect(find.byType(TimeSlotWidget), findsOne);
      await tester.tap(find.byType(TimeSlotWidget));
      await tester.pumpAndSettle();
      expect(find.byType(TimePicker), findsNothing);
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

    testWidgets('scales schedule grid', (tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer((_) async => []);

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(),
      ));
      await tester.pumpAndSettle();

      final widgetFinder = find.byType(ScheduleGrid);
      final grid = (tester.state(widgetFinder) as ScheduleGridState);
      final center = tester.getCenter(widgetFinder);

      expect(grid.hourHeight, 26.0);

      // create two touches:
      final touch1 = await tester.startGesture(center.translate(-10, 0));
      final touch2 = await tester.startGesture(center.translate(10, 0));

      // zoom in:
      await touch1.moveBy(const Offset(-100, 0));
      await touch2.moveBy(const Offset(100, 0));
      await tester.pump();

      final biggerHeight = grid.hourHeight;
      expect(biggerHeight > 26.0, true);

      // zoom out:
      await touch1.moveBy(const Offset(10, 0));
      await touch2.moveBy(const Offset(-10, 0));
      await tester.pump();

      final smallerHeight = grid.hourHeight;
      expect(smallerHeight < biggerHeight, true);

      // cancel touches:
      await touch1.cancel();
      await touch2.cancel();
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

    testWidgets('Flips time slot when dragging above start', (tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer((_) async => []);
      when(mockScheduleController.createTimeSlot(any, any, any))
          .thenAnswer((_) async {});

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(),
      ));
      await tester.pumpAndSettle();

      final dayColumn = find.byType(DayColumn).at(3);
      final newTimeSlotFinder = find.byType(NewTimeSlot).at(3);
      final newTimeSlot = (tester.state(newTimeSlotFinder) as NewTimeSlotState);

      final center = tester.getCenter(dayColumn);

      expect(newTimeSlot.top, 0);
      expect(newTimeSlot.start, 0);
      expect(newTimeSlot.height, 0);

      // create touch:
      final touch = await tester.startGesture(center.translate(0, 0));
      await tester.pump(const Duration(milliseconds: 500));

      final initTop = newTimeSlot.top;
      final initHeight = newTimeSlot.height;
      expect(initTop > 0, true);
      expect(newTimeSlot.start == initTop, true);
      expect(initHeight > 0, true);

      // drag down:
      await touch.moveBy(const Offset(0, 100));
      await tester.pump();

      expect(newTimeSlot.top == initTop, true);
      expect(newTimeSlot.height > initHeight, true);
      final slotHeight = newTimeSlot.height;

      // drag up:
      await touch.moveBy(const Offset(0, -200));
      await tester.pump();

      expect(newTimeSlot.top < initTop, true);
      expect(newTimeSlot.height == slotHeight, true);

      // cancel touches:
      await touch.cancel();
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

    testWidgets('Time Picker - change start time and cancel', (tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer(
          (_) async => [TimeSlot(id: '1', day: 1, start: 2, length: 2)]);
      when(mockScheduleController.isModifiable).thenAnswer((_) => true);
      when(mockScheduleController.canCreateMeeting).thenAnswer((_) => false);

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TimeSlotWidget), findsOne);
      await tester.tap(find.byType(TimeSlotWidget));
      await tester.pumpAndSettle();
      expect(find.byType(TimePicker), findsOne);

      expect(find.byKey(startTimeSlot), findsOne);
      expect(find.byKey(endTimeSlot), findsOne);
      expect(find.byKey(deleteTimeSlotKey), findsOne);

      await tester.tap(find.byKey(startTimeSlot));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOne);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      verifyNever(mockScheduleController.updateTimeSlot('1', 1, 7, 2));
    });

    testWidgets('Time Picker - change end time and cancel', (tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer(
          (_) async => [TimeSlot(id: '1', day: 1, start: 2, length: 2)]);
      when(mockScheduleController.isModifiable).thenAnswer((_) => true);
      when(mockScheduleController.canCreateMeeting).thenAnswer((_) => false);
      when(mockScheduleController.deleteTimeSlot(any)).thenAnswer((_) async {});

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TimeSlotWidget), findsOne);
      await tester.tap(find.byType(TimeSlotWidget));
      await tester.pumpAndSettle();
      expect(find.byType(TimePicker), findsOne);

      expect(find.byKey(startTimeSlot), findsOne);
      expect(find.byKey(endTimeSlot), findsOne);
      expect(find.byKey(deleteTimeSlotKey), findsOne);

      await tester.tap(find.byKey(endTimeSlot));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOne);
      await tester.tap(find.text('Cancel'));
      verifyNever(mockScheduleController.updateTimeSlot('1', 1, 7, 2));
    });

    testWidgets('Time Picker - delete time slot', (tester) async {
      when(mockScheduleController.getTimeSlots()).thenAnswer(
          (_) async => [TimeSlot(id: '1', day: 1, start: 2, length: 2)]);
      when(mockScheduleController.isModifiable).thenAnswer((_) => true);
      when(mockScheduleController.canCreateMeeting).thenAnswer((_) => false);
      when(mockScheduleController.deleteTimeSlot(any)).thenAnswer((_) async {});

      await tester.pumpWidget(const MaterialApp(
        home: SchedulePage(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TimeSlotWidget), findsOne);
      await tester.tap(find.byType(TimeSlotWidget));
      await tester.pumpAndSettle();
      expect(find.byType(TimePicker), findsOne);

      expect(find.byKey(startTimeSlot), findsOne);
      expect(find.byKey(endTimeSlot), findsOne);
      expect(find.byKey(deleteTimeSlotKey), findsOne);

      when(mockScheduleController.deleteTimeSlot(any)).thenAnswer((_) async {});
      await tester.tap(find.byKey(deleteTimeSlotKey));
      verify(mockScheduleController.deleteTimeSlot('1')).called(1);
    });
  });
}
