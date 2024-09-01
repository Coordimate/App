import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/meeting_tiles.dart';
import 'package:coordimate/pages/meeting_info_page.dart';
import 'package:coordimate/pages/meetings_archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/client/meetings.dart';
import '../test.mocks.dart';
import 'package:mockito/mockito.dart';

void main() {
  late MockMeetingController mockMeetingController;

  setUp(() {
    mockMeetingController = MockMeetingController();

    AppState.meetingController = mockMeetingController;
    AppState.testMode = true;
  });

  testWidgets('empty archive', (WidgetTester tester) async {
    when(mockMeetingController.fetchMeetings()).thenAnswer((_) async => [meetingTileAcceptedFuture]);

    await tester.pumpWidget(MaterialApp(
      home: MeetingsArchivePage(
          meetings: const [],
          fetchMeetings: mockMeetingController.fetchMeetings),
    ));

    await tester.pumpAndSettle();

    expect(find.text("Archive"), findsOneWidget);
    expect(find.text("Declined Upcoming Meetings"), findsNothing);
    expect(find.text("Passed Meetings"), findsNothing);
    expect(find.byType(ArchivedMeetingTile), findsNothing);
    expect(find.byType(AcceptedMeetingTile), findsNothing);

    verifyNever(mockMeetingController.fetchMeetings());
  });

  testWidgets('possible meeting tiles are shown', (WidgetTester tester) async {
    when(mockMeetingController.fetchMeetings()).thenAnswer((_) async => [meetingTileDeclinedFuture, meetingTileDeclinedPast, meetingTileAcceptedPast]);

    await tester.pumpWidget(MaterialApp(
      home: MeetingsArchivePage(
          meetings: [meetingTileDeclinedFuture, meetingTileDeclinedPast, meetingTileAcceptedPast], 
          fetchMeetings: mockMeetingController.fetchMeetings),
    ));

    await tester.pumpAndSettle();
    
    expect(find.text("Declined Upcoming Meetings"), findsOneWidget);
    expect(find.text("Passed Meetings"), findsOneWidget);
    expect(find.byType(ArchivedMeetingTile), findsExactly(2));
    expect(find.byType(AcceptedMeetingTile), findsExactly(1));

    verifyNever(mockMeetingController.fetchMeetings());
  });

  testWidgets('redirect to archived passed declined meeting and back', (WidgetTester tester) async {
    when(mockMeetingController.fetchMeetings()).thenAnswer((_) async => [meetingTileDeclinedPast]);
    when(mockMeetingController.fetchArchivedMeetings()).thenAnswer((_) async => [meetingTileDeclinedPast]);
    when(mockMeetingController.fetchMeetingDetails(meetingTileDeclinedPast.id)).thenAnswer((_) async => meetingDetailsPastDeclined);


    await tester.pumpWidget(MaterialApp(
      home: MeetingsArchivePage(
          meetings: [meetingTileDeclinedPast],
          fetchMeetings: mockMeetingController.fetchMeetings),
    ));

    await tester.pumpAndSettle();

    expect(find.text("Declined Upcoming Meetings"), findsNothing);
    expect(find.text("Passed Meetings"), findsOneWidget);
    expect(find.byType(ArchivedMeetingTile), findsExactly(1));
    expect(find.byType(AcceptedMeetingTile), findsNothing);

    await tester.tap(find.byType(ArchivedMeetingTile));
    await tester.pumpAndSettle();

    expect(find.byType(MeetingDetailsPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(MeetingsArchivePage), findsOneWidget);

    verify(mockMeetingController.fetchMeetingDetails(meetingTileDeclinedPast.id)).called(1);
    verify(mockMeetingController.fetchMeetings()).called(1);
  });

}
