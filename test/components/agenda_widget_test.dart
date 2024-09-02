import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:coordimate/components/agenda.dart';
import 'package:coordimate/models/agenda_point.dart';
import 'package:coordimate/app_state.dart';
import '../test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockMeetingController = MockMeetingController();
  AppState.meetingController = mockMeetingController;

  group('MeetingAgenda Tests', () {
    testWidgets('Renders CircularProgressIndicator while loading',
        (WidgetTester tester) async {
      when(mockMeetingController.getAgendaPoints('test_meeting_id'))
          .thenAnswer((_) async => []);

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
      when(mockMeetingController.getAgendaPoints('test_meeting_id'))
          .thenAnswer((_) async => agendaPoints);

      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingAgenda(meetingId: 'test_meeting_id'),
        ),
      );

      await tester.pump();
      expect(find.text('Point 1'), findsOneWidget);
      expect(find.text('Point 2'), findsOneWidget);
    });

    testWidgets('Calls createAgendaPoint when button pressed',
        (WidgetTester tester) async {
      when(mockMeetingController.getAgendaPoints('test_meeting_id'))
          .thenAnswer((_) async => []);
      when(mockMeetingController.createAgendaPoint('test_meeting_id', '', 0))
          .thenAnswer((_) async {});

      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingAgenda(meetingId: 'test_meeting_id'),
        ),
      );

      final addButtonFinder = find.byType(IconButton);
      await tester.tap(addButtonFinder);
      await tester.pump();

      verify(mockMeetingController.createAgendaPoint('test_meeting_id', '', 0))
          .called(1);
    });

    testWidgets('Agenda item editable after tap', (WidgetTester tester) async {
      when(mockMeetingController.getAgendaPoints('test_meeting_id'))
          .thenAnswer((_) async => [AgendaPoint(text: 'foo', level: 0)]);

      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingAgenda(meetingId: 'test_meeting_id'),
        ),
      );
      await tester.pumpAndSettle();

      final point = find.text('foo');
      await tester.tap(point);
      await tester.pumpAndSettle();

      await tester.enterText(point, 'bar');
      await tester.tap(find.text('Agenda'));

      expect(find.text('bar'), findsOne);
      verify(mockMeetingController.updateAgenda(any, any)).called(1);
    });

    testWidgets('Reorder agenda items', (tester) async {
      when(mockMeetingController.getAgendaPoints('test_meeting_id')).thenAnswer(
          (_) async => [
                AgendaPoint(text: 'first', level: 0),
                AgendaPoint(text: 'last', level: 0)
              ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingAgenda(meetingId: 'test_meeting_id'),
        ),
      );
      await tester.pumpAndSettle();

      var first = (tester.state(find.byType(AgendaPointWidget).first)
          as AgendaPointWidgetState);
      var last = (tester.state(find.byType(AgendaPointWidget).last)
          as AgendaPointWidgetState);
      expect(first.text, 'first');
      expect(last.text, 'last');

      final TestGesture drag =
          await tester.startGesture(tester.getCenter(find.text('first')));
      await tester.pump(kLongPressTimeout + kPressTimeout);

      await drag.moveTo(tester.getCenter(find.text('last')));
      await drag.up();
      await tester.pumpAndSettle();

      verify(mockMeetingController.updateAgenda(any, any)).called(1);
    });

    testWidgets('Agenda item level changes on drag',
        (WidgetTester tester) async {
      when(mockMeetingController.getAgendaPoints('test_meeting_id'))
          .thenAnswer((_) async => [AgendaPoint(text: 'foo', level: 0)]);
      when(mockMeetingController.updateAgenda(any, any))
          .thenAnswer((_) async => [AgendaPoint(text: 'foo', level: 1)]);

      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingAgenda(meetingId: 'test_meeting_id'),
        ),
      );
      await tester.pumpAndSettle();

      final text = find.text('foo');
      var point = find.byType(AgendaPointWidget);
      var pointState = (tester.state(point) as AgendaPointWidgetState);

      expect(pointState.level, 0);

      await tester.drag(text, const Offset(100, 0));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      verify(mockMeetingController.updateAgenda(any, any)).called(1);
    });

    testWidgets('Calls deleteAgendaPoint when delete icon tapped',
        (WidgetTester tester) async {
      when(mockMeetingController.getAgendaPoints('test_meeting_id'))
          .thenAnswer((_) async => [AgendaPoint(text: 'foo', level: 0)]);
      when(mockMeetingController.deleteAgendaPoint('test_meeting_id', 0))
          .thenAnswer((_) async {});

      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingAgenda(meetingId: 'test_meeting_id'),
        ),
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingAgenda(meetingId: 'test_meeting_id'),
        ),
      );
      await tester.pumpAndSettle();

      var point = find.byType(AgendaPointWidget);
      expect(point, findsOne);

      await tester.drag(point, const Offset(-500.0, 0.0));

      var pointState = (tester.state(point) as AgendaPointWidgetState);
      pointState.showDelete = true;
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete), findsOneWidget);
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      verify(mockMeetingController.deleteAgendaPoint('test_meeting_id', 0))
          .called(1);
    });
  });
}
