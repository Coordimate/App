import 'package:coordimate/controllers/meeting_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

import 'package:mockito/annotations.dart';

import 'package:coordimate/components/agenda.dart';
import 'package:coordimate/models/agenda_point.dart';
import 'package:coordimate/app_state.dart';
import 'agenda_widget_test.mocks.dart';

@GenerateMocks([MeetingController])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // TestWidgetsFlutterBinding.ensureInitialized();

  final mockMeetingController = MockMeetingController();
  AppState.meetingController = mockMeetingController;

  group('MeetingAgenda Tests', () {
    testWidgets('Renders CircularProgressIndicator while loading', (WidgetTester tester) async {
      when(mockMeetingController.getAgendaPoints('test_meeting_id')).thenAnswer((_) async => []);

      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingAgenda(meetingId: 'test_meeting_id'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Displays agenda points', (WidgetTester tester) async {
      final agendaPoints = [
        AgendaPoint(text: 'Point 1', level: 0),
        AgendaPoint(text: 'Point 2', level: 1),
      ];
      when(mockMeetingController.getAgendaPoints('test_meeting_id')).thenAnswer((_) async => agendaPoints);

      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingAgenda(meetingId: 'test_meeting_id'),
        ),
      );

      await tester.pump(); // Trigger a frame.
      expect(find.text('Point 1'), findsOneWidget);
      expect(find.text('Point 2'), findsOneWidget);
    });

    testWidgets('Calls createAgendaPoint when button pressed', (WidgetTester tester) async {
      when(mockMeetingController.getAgendaPoints('test_meeting_id')).thenAnswer((_) async => []);
      when(mockMeetingController.createAgendaPoint('test_meeting_id', '', 0)).thenAnswer((_) async {});

      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingAgenda(meetingId: 'test_meeting_id'),
        ),
      );

      final addButtonFinder = find.byType(IconButton);
      await tester.tap(addButtonFinder);
      await tester.pump();

      verify(mockMeetingController.createAgendaPoint('test_meeting_id', '', 0)).called(1);
    });

    // FIXME: this test works with flutter run, but not with flutter test
    // testWidgets('Calls deleteAgendaPoint when delete icon tapped', (WidgetTester tester) async {
    //   final agendaPoints = [
    //     AgendaPoint(text: 'Point 1', level: 0),
    //   ];
    //   when(mockMeetingController.getAgendaPoints('test_meeting_id')).thenAnswer((_) async => agendaPoints);
    //   when(mockMeetingController.deleteAgendaPoint('test_meeting_id', 0)).thenAnswer((_) async {});
    //
    //   await tester.pumpWidget(
    //     const MaterialApp(
    //       home: MeetingAgenda(meetingId: 'test_meeting_id'),
    //     ),
    //   );
    //
    //   await tester.pump(); // Trigger a frame.
    //   await tester.drag(find.text('Point 1'), const Offset(-500, 0));
    //   await tester.pumpAndSettle(const Duration(milliseconds: 400));
    //
    //   final deleteFinder = find.byIcon(Icons.delete);
    //   await tester.tap(deleteFinder);
    //   await tester.pump();
    //
    //   verify(mockMeetingController.deleteAgendaPoint('test_meeting_id', 0)).called(1);
    // });
  });
}
