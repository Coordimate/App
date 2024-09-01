import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/meeting_tiles.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/pages/meeting_info_page.dart';
import 'package:coordimate/pages/meetings_archive.dart';
import 'package:coordimate/pages/meetings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/client/meetings.dart';
import '../test.mocks.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:mockito/mockito.dart';

void main() {
  late MockMeetingController mockMeetingController;

  setUp(() {
    mockMeetingController = MockMeetingController();

    AppState.meetingController = mockMeetingController;
    AppState.testMode = true;
  });

  group('Meeting invitations', () {

    testWidgets('accept meeting invitation', (WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      when(mockMeetingController.answerInvitation(true, meetingTileInvitationFuture.id)).thenAnswer((_) async => MeetingStatus.accepted);

      int callCount = 0;
      when(AppState.meetingController.fetchMeetings()).thenAnswer((_) async {
        if (callCount == 0) {
          callCount++;
          return [meetingTileInvitationFuture];
        } else {
          return [meetingTileAcceptedFuture];
        }
      });

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const MeetingsPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(NewMeetingTile), findsOneWidget);
      expect(find.byKey(acceptButtonKey), findsOneWidget);

      await tester.tap(find.byKey(acceptButtonKey));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Meeting accepted'), findsOneWidget);


      expect(find.byType(AcceptedMeetingTile), findsOneWidget);
      verify(AppState.meetingController.answerInvitation(true, meetingTileInvitationFuture.id)).called(1);
      verify(AppState.meetingController.fetchMeetings()).called(2);

    });

    testWidgets('decline meeting invitation', (WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      when(mockMeetingController.answerInvitation(false, meetingTileInvitationFuture.id)).thenAnswer((_) async => MeetingStatus.declined);
      int callCount = 0;
      when(AppState.meetingController.fetchMeetings()).thenAnswer((_) async {
        if (callCount == 0) {
          callCount++;
          return [meetingTileInvitationFuture];
        } else {
          return [meetingTileDeclinedFuture];
        }
      });

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const MeetingsPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(NewMeetingTile), findsOneWidget);
      expect(find.byKey(declineButtonKey), findsOneWidget);

      await tester.tap(find.byKey(declineButtonKey));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Meeting declined'), findsOneWidget);

      expect(find.byType(NewMeetingTile), findsNothing);
      verify(AppState.meetingController.answerInvitation(false, meetingTileInvitationFuture.id)).called(1);
      verify(AppState.meetingController.fetchMeetings()).called(2);

    });

  });

  testWidgets('redirect to archive page', (WidgetTester tester) async {
    when(mockMeetingController.fetchMeetings()).thenAnswer((_) async => [meetingTileDeclinedTomorrow, meetingTileDeclinedFuture]);

    await tester.pumpWidget(const MaterialApp(
      home: MeetingsPage(),
    ));

    await tester.pumpAndSettle();

    expect(find.text("Archive"), findsOneWidget);
    await tester.tap(find.text("Archive"));
    await tester.pumpAndSettle();

    expect(find.byType(MeetingsArchivePage), findsOneWidget);
  });

  group('Calendar slots', () {

    testWidgets('calendar days', (WidgetTester tester) async {
      when(mockMeetingController.fetchMeetings()).thenAnswer((_) async => []);

      await tester.pumpWidget(const MaterialApp(
        home: MeetingsPage(),
      ));

      final calendarBox = find.byKey(Key('calendarDayBox${DateTime.now().day.toString()}'));
      final calendarBox1 = find.byKey(Key('calendarDayBox${DateTime.now().add(const Duration(days: 1)).day.toString()}'));
      final calendarBox2 = find.byKey(Key('calendarDayBox${DateTime.now().add(const Duration(days: 2)).day.toString()}'));
      final calendarBox3 = find.byKey(Key('calendarDayBox${DateTime.now().add(const Duration(days: 3)).day.toString()}'));
      final calendarBox4 = find.byKey(Key('calendarDayBox${DateTime.now().add(const Duration(days: 4)).day.toString()}'));
      expect(calendarBox, findsOneWidget);
      expect(calendarBox1, findsOneWidget);
      expect(calendarBox2, findsOneWidget);
      expect(calendarBox3, findsOneWidget);
      expect(calendarBox4, findsOneWidget);

      verify(mockMeetingController.fetchMeetings()).called(1);
    });

    testWidgets('invitation, accepted meeting for tomorrow', (WidgetTester tester) async {
      when(mockMeetingController.fetchMeetings()).thenAnswer((_) async => [
        meetingTileInvitationTomorrow,
        meetingTileAcceptedTomorrow]);

      await tester.pumpWidget(const MaterialApp(
        home: MeetingsPage(),
      ));

      await tester.pumpAndSettle();

      final calendarBox1 = find.byKey(Key('calendarDayBox${DateTime.now().add(const Duration(days: 1)).day.toString()}'));
      expect(calendarBox1, findsOneWidget);

      await tester.tap(calendarBox1);
      await tester.pumpAndSettle();

      expect(find.byKey(Key('newMeetingTile${meetingTileInvitationTomorrow.id}')), findsExactly(2));
      expect(find.byKey(Key('acceptedMeetingTile${meetingTileAcceptedTomorrow.id}')), findsExactly(2));
      
      verify(mockMeetingController.fetchMeetings()).called(1);
    });

    // testWidgets('accept meeting invitation from calendar', (WidgetTester tester) async {
    //   final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    //
    //   when(mockMeetingController.answerInvitation(true, meetingTileInvitationTomorrow.id)).thenAnswer((_) async => MeetingStatus.accepted);
    //   when(AppState.meetingController.fetchMeetings()).thenAnswer((_) async => [meetingTileInvitationTomorrow]);
    //
    //   await tester.pumpWidget(MaterialApp(
    //     scaffoldMessengerKey: scaffoldMessengerKey,
    //     home: const MeetingsPage(),
    //   ));
    //
    //   await tester.pumpAndSettle();
    //
    //   expect(find.byType(NewMeetingTile), findsExactly(1));
    //
    //   final calendarBox1 = find.byKey(Key('calendarDayBox${DateTime.now().add(const Duration(days: 1)).day.toString()}'));
    //   expect(calendarBox1, findsOneWidget);
    //
    //   await tester.tap(calendarBox1);
    //   await tester.pumpAndSettle();
    //
    //   expect(find.byType(NewMeetingTile), findsExactly(2));
    //
    //   final calendarMeetingTile = find.descendant(of: find.byType(DraggableBottomSheet), matching: find.byType(NewMeetingTile));
    //   final invitationActionButtonFinder = find.descendant(
    //     of: calendarMeetingTile,
    //     matching: find.byWidgetPredicate(
    //       (widget) => widget is InvitationActionButton && widget.color == lightBlue,
    //     ),
    //   );
    //   expect(calendarMeetingTile, findsOneWidget);
    //   expect(invitationActionButtonFinder, findsOneWidget);
    //
    //   final draggableBottomSheetFinder = find.byType(DraggableBottomSheet);
    //
    //   final draggableBottomSheet = tester.getTopLeft(draggableBottomSheetFinder);
    //   await tester.dragFrom(draggableBottomSheet, const Offset(0, -400));
    //   await tester.pumpAndSettle();
    //
    //   await tester.tap(invitationActionButtonFinder);
    //   await tester.pumpAndSettle();
    //
    //   expect(find.byType(SnackBar), findsOneWidget);
    //   expect(find.text('Meeting accepted'), findsOneWidget);
    //
    //   verify(AppState.meetingController.answerInvitation(true, meetingTileInvitationTomorrow.id)).called(1);
    //   verify(AppState.meetingController.fetchMeetings()).called(2);
    //
    // });

  });
  
  testWidgets('does not show archived tile', (WidgetTester tester) async {
    when(mockMeetingController.fetchMeetings()).thenAnswer((_) async => [meetingTileDeclinedFuture]);
    
    await tester.pumpWidget(const MaterialApp(
      home: MeetingsPage(),
    ));
    
    await tester.pumpAndSettle();
    
    expect(find.byType(ArchivedMeetingTile), findsNothing);
  });

  group('redirect to meeting info page', () {

    testWidgets('redirect to meeting invitation page', (WidgetTester tester) async {
      when(mockMeetingController.fetchMeetings()).thenAnswer((_) async => [meetingTileInvitationFuture]);
      when(mockMeetingController.fetchMeetingDetails(meetingTileInvitationFuture.id)).thenAnswer((_) async => meetingDetailsFuturePending);

      await tester.pumpWidget(const MaterialApp(
        home: MeetingsPage(),
      ));

      await tester.pumpAndSettle();

      final meetingTile = find.byType(NewMeetingTile);
      expect(meetingTile, findsOneWidget);

      await tester.tap(meetingTile);
      await tester.pumpAndSettle();

      expect(find.byType(MeetingDetailsPage), findsOneWidget);

      verify(mockMeetingController.fetchMeetingDetails(meetingTileInvitationFuture.id)).called(1);
      verify(mockMeetingController.fetchMeetings()).called(1);
    });

    testWidgets('redirect to accepted meeting page', (WidgetTester tester) async {
      when(mockMeetingController.fetchMeetings()).thenAnswer((_) async => [meetingTileAcceptedFuture]);
      when(mockMeetingController.fetchMeetingDetails(meetingTileInvitationFuture.id)).thenAnswer((_) async => meetingDetailsFutureAccepted);

      await tester.pumpWidget(const MaterialApp(
        home: MeetingsPage(),
      ));

      await tester.pumpAndSettle();

      final meetingTile = find.byType(AcceptedMeetingTile);
      expect(meetingTile, findsOneWidget);

      await tester.tap(meetingTile);
      await tester.pumpAndSettle();

      expect(find.byType(MeetingDetailsPage), findsOneWidget);

      verify(mockMeetingController.fetchMeetingDetails(meetingTileAcceptedFuture.id)).called(1);
      verify(mockMeetingController.fetchMeetings()).called(1);
    });

  });

}
