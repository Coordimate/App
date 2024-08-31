import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/agenda.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/pop_up_dialog.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/pages/meeting_info_page.dart';
import 'package:coordimate/pages/meeting_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/client/data_provider.dart';
import '../test.mocks.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:mockito/mockito.dart';

void main() {
  late MeetingDetails mockMeetingDetails1;
  late MeetingDetails mockMeetingDetails2;
  late MeetingDetails mockMeetingDetails3;
  late MeetingDetails mockMeetingDetails4;
  late MeetingDetails mockMeetingDetails5;
  late MeetingDetails mockMeetingDetails6;
  late MeetingDetails mockMeetingDetails7;
  late MeetingDetails mockMeetingDetails8;
  late MockMeetingController mockMeetingController;
  late MockAuthorizationController mockAuthController;

  setUp(() {
    mockMeetingController = MockMeetingController();
    mockAuthController = MockAuthorizationController();

    AppState.meetingController = mockMeetingController;
    AppState.authController = mockAuthController;
    AppState.testMode = true;

    mockMeetingDetails1 = MeetingDetails(
      id: '12345',
      title: DataProvider.meetingTitle1,
      description: DataProvider.meetingDescr1,
      admin: Participant(id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
      participants: [
        Participant(id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
        Participant(id: '2', username: DataProvider.username1, status: 'accepted'),
        Participant(id: '3', username: DataProvider.username2, status: 'needs_acceptance'),
      ],
      status: MeetingStatus.accepted,
      dateTime: DataProvider.dateTimeFutureObj,
      duration: 60,
      groupName: DataProvider.groupName1,
      groupId: '1',
      isFinished: false,
      summary: 'Summary of the meeting',
      meetingLink: DataProvider.meetingLink,
    );
    mockMeetingDetails2 = MeetingDetails(
      id: '12345',
      title: DataProvider.meetingTitle1,
      description: DataProvider.meetingDescr1,
      admin: Participant(
          id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
      participants: [
        Participant(
            id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
        Participant(
            id: '2', username: DataProvider.username1, status: 'accepted'),
        Participant(id: '3',
            username: DataProvider.username2,
            status: 'needs_acceptance'),
      ],
      status: MeetingStatus.needsAcceptance,
      dateTime: DataProvider.dateTimeFutureObj,
      duration: 60,
      groupName: DataProvider.groupName1,
      groupId: '1',
      isFinished: false,
      summary: 'Summary of the meeting',
      meetingLink: DataProvider.meetingLink,
    );
    mockMeetingDetails3 = MeetingDetails(
      id: '12345',
      title: DataProvider.meetingTitle1,
      description: DataProvider.meetingDescr1,
      admin: Participant(
          id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
      participants: [
        Participant(
            id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
        Participant(
            id: '2', username: DataProvider.username1, status: 'accepted'),
        Participant(id: '3',
            username: DataProvider.username2,
            status: 'needs_acceptance'),
      ],
      status: MeetingStatus.accepted,
      dateTime: DataProvider.dateTimeFutureObj,
      duration: 60,
      groupName: DataProvider.groupName1,
      groupId: '1',
      isFinished: false,
      summary: 'Summary of the meeting',
      meetingLink: DataProvider.meetingLink,
    );
    mockMeetingDetails4 = MeetingDetails(
      id: '12345',
      title: DataProvider.meetingTitle1,
      description: DataProvider.meetingDescr1,
      admin: Participant(
          id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
      participants: [
        Participant(
            id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
        Participant(
            id: '2', username: DataProvider.username1, status: 'accepted'),
        Participant(id: '3',
            username: DataProvider.username2,
            status: 'declined'),
      ],
      status: MeetingStatus.declined,
      dateTime: DataProvider.dateTimeFutureObj,
      duration: 60,
      groupName: DataProvider.groupName1,
      groupId: '1',
      isFinished: false,
      summary: 'Summary of the meeting',
      meetingLink: DataProvider.meetingLink,
    );
    mockMeetingDetails5 = MeetingDetails(
      id: '12345',
      title: DataProvider.meetingTitle1,
      description: DataProvider.meetingDescr1,
      admin: Participant(
          id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
      participants: [
        Participant(
            id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
        Participant(
            id: '2', username: DataProvider.username1, status: 'accepted'),
        Participant(id: '3',
            username: DataProvider.username2,
            status: 'declined'),
      ],
      status: MeetingStatus.declined,
      dateTime: DataProvider.dateTimeFutureObj,
      duration: 60,
      groupName: DataProvider.groupName1,
      groupId: '1',
      isFinished: true,
      summary: 'Summary of the meeting',
      meetingLink: DataProvider.meetingLink,
    );
    mockMeetingDetails6 = MeetingDetails(
      id: '12345',
      title: DataProvider.meetingTitle1,
      description: DataProvider.meetingDescr1,
      admin: Participant(id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
      participants: [
        Participant(id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
        Participant(id: '2', username: DataProvider.username1, status: 'accepted'),
        Participant(id: '3', username: DataProvider.username2, status: 'needs_acceptance'),
      ],
      status: MeetingStatus.needsAcceptance,
      dateTime: DataProvider.dateTimePastObj,
      duration: 60,
      groupName: DataProvider.groupName1,
      groupId: '1',
      isFinished: false,
      summary: 'Summary of the meeting',
      meetingLink: DataProvider.meetingLink,
    );
    mockMeetingDetails7 = MeetingDetails(
      id: '12345',
      title: DataProvider.meetingTitle1,
      description: DataProvider.meetingDescr1,
      admin: Participant(id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
      participants: [
        Participant(id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
        Participant(id: '2', username: DataProvider.username1, status: 'accepted'),
        Participant(id: '3', username: DataProvider.username2, status: 'needs_acceptance'),
      ],
      status: MeetingStatus.needsAcceptance,
      dateTime: DataProvider.dateTimeFutureObj,
      duration: 60,
      groupName: DataProvider.groupName1,
      groupId: '1',
      isFinished: true,
      summary: 'Summary of the meeting',
      meetingLink: DataProvider.meetingLink,
    );
    mockMeetingDetails8 = MeetingDetails(
      id: '12345',
      title: DataProvider.meetingTitle1,
      description: DataProvider.meetingDescr1,
      admin: Participant(
          id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
      participants: [
        Participant(
            id: '1', username: DataProvider.usernameAdmin, status: 'accepted'),
        Participant(
            id: '2', username: DataProvider.username1, status: 'accepted'),
        Participant(id: '3',
            username: DataProvider.username2,
            status: 'accepted'),
      ],
      status: MeetingStatus.accepted,
      dateTime: DataProvider.dateTimeFutureObj,
      duration: 60,
      groupName: DataProvider.groupName1,
      groupId: '1',
      isFinished: true,
      summary: 'Summary of the meeting',
      meetingLink: DataProvider.meetingLink,
    );
  });

  group('Not admin user who accepted invitation', () {

    testWidgets('displays meeting title, description, information, participants', (WidgetTester tester) async {
      when(mockAuthController.userId).thenReturn('2');

      await tester.pumpWidget(MaterialApp(
        home: MeetingDetailsPage(meeting: mockMeetingDetails1),
      ));

      expect(find.text(DataProvider.meetingTitle1), findsOneWidget);
      expect(find.text(DataProvider.meetingDescr1), findsOneWidget);

      expect(find.text(mockMeetingDetails1.getFormattedDate(DataProvider.dateTimeFutureObj)), findsOneWidget);
      expect(find.text(mockMeetingDetails1.getFormattedTime(DataProvider.dateTimeFutureObj)), findsOneWidget);
      expect(find.text(DataProvider.groupName1), findsOneWidget);
      expect(find.text(DataProvider.usernameAdmin), findsExactly(2));

      expect(find.byKey(linkPlaceholderFieldKey), findsOneWidget);
      expect(find.text(DataProvider.meetingLink), findsOneWidget);

      expect(find.byKey(meetOfflineButtonKey), findsOneWidget);
      expect(find.byKey(meetingAgendaButtonKey), findsOneWidget);
      expect(find.byKey(finishMeetingButtonKey), findsOneWidget);
      expect(find.byKey(summaryButtonKey), findsNothing);
      expect(find.byKey(answerButtonsKey), findsNothing);
      expect(find.byKey(attendMeetingButtonKey), findsNothing);
      expect(find.byKey(invitationDeclinedButtonKey), findsNothing);

      expect(find.text("Participants"), findsOneWidget);

      expect(find.text(DataProvider.username1), findsOneWidget);
      expect(find.text(DataProvider.username2), findsOneWidget);
      expect(find.text('accepted'), findsExactly(2));
      expect(find.text('needs_acceptance'), findsOneWidget);

      expect(find.text('Delete Meeting'), findsNothing);
    });

    testWidgets('clicks on decline meeting and snack bar shows', (WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      when(mockAuthController.userId).thenReturn('2');
      when(mockMeetingController.answerInvitation(false, '12345'))
          .thenAnswer((_) async => MeetingStatus.declined);

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: MeetingDetailsPage(meeting: mockMeetingDetails1),
      ));

      await tester.ensureVisible(find.byKey(withdrawMeetingButtonKey));

      // // Click on decline meeting button and then NO
      await tester.tap(find.byKey(withdrawMeetingButtonKey));
      await tester.pumpAndSettle();
      expect(find.byKey(alertDialogKey), findsOneWidget);
      expect(find.text('Do you want to withdraw from meeting?'), findsOneWidget);
      await tester.tap(find.byKey(noButtonKey));
      await tester.pumpAndSettle();
      expect(find.byKey(alertDialogKey), findsNothing);
      expect(find.byKey(withdrawMeetingButtonKey), findsOneWidget);

      // Click on attend meeting button and then YES
      await tester.tap(find.byKey(withdrawMeetingButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(yesButtonKey));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Meeting declined'), findsOneWidget);
      expect(find.byKey(withdrawMeetingButtonKey), findsNothing);
    });

    testWidgets('redirects to meeting agenda page', (WidgetTester tester) async {
      when(mockAuthController.userId).thenReturn('2');
      when(mockMeetingController.getAgendaPoints(mockMeetingDetails1.id)).thenAnswer((_) async => []);

      await tester.pumpWidget(MaterialApp(
        home: MeetingDetailsPage(meeting: mockMeetingDetails1),
      ));

      expect(find.byKey(meetingAgendaButtonKey), findsOneWidget);

      await tester.tap(find.byKey(meetingAgendaButtonKey));
      await tester.pumpAndSettle();

      expect(find.byType(MeetingAgenda), findsOneWidget);

      expect(find.text('Agenda'), findsOneWidget);

      verify(mockMeetingController.getAgendaPoints(mockMeetingDetails1.id)).called(1);
    });

    testWidgets('redirects to meeting summary page', (WidgetTester tester) async {
      when(mockAuthController.userId).thenReturn('3');
      when(mockMeetingController.fetchMeetingSummary(mockMeetingDetails8.id)).thenAnswer((_) async => '');

      await tester.pumpWidget(MaterialApp(
        home: MeetingDetailsPage(meeting: mockMeetingDetails8),
      ));

      expect(find.byKey(summaryButtonKey), findsOneWidget);

      await tester.tap(find.byKey(summaryButtonKey));
      await tester.pumpAndSettle();

      expect(find.byType(SummaryPage), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(MeetingDetailsPage), findsOneWidget);

      verify(mockMeetingController.fetchMeetingSummary(mockMeetingDetails8.id)).called(1);
    });

    testWidgets('finish meeting and show summary button', (WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
      when(mockAuthController.userId).thenReturn('2');
      when(mockMeetingController.finishMeeting(mockMeetingDetails1.id)).thenAnswer((_) async => true);

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: MeetingDetailsPage(meeting: mockMeetingDetails1),
      ));

      final finishMeetingButton = find.byKey(finishMeetingButtonKey);

      await tester.tap(finishMeetingButton);
      await tester.pumpAndSettle();
      expect(find.byType(CustomPopUpDialog), findsOneWidget);
      expect(find.text("Do you want to finish the meeting?"), findsOneWidget);
      await tester.tap(find.byKey(yesButtonKey));
      await tester.pumpAndSettle();
      expect(find.byType(CustomPopUpDialog), findsNothing);
      expect(find.byKey(finishMeetingButtonKey), findsNothing);
      expect(find.byKey(summaryButtonKey), findsOneWidget);
      await tester.tap(find.byKey(summaryButtonKey));
      await tester.pumpAndSettle();
      expect(find.byType(SummaryPage), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);

      verify(mockMeetingController.finishMeeting(mockMeetingDetails1.id)).called(1);
    });

    testWidgets('opens maps for offline meeting', (WidgetTester tester) async {
      when(mockAuthController.userId).thenReturn('2');
      when(mockMeetingController.suggestMeetingLocation(mockMeetingDetails1.id))
          .thenAnswer((_) async => 'https://www.google.com/maps/place/');

      await tester.pumpWidget(MaterialApp(
        home: MeetingDetailsPage(meeting: mockMeetingDetails1),
      ));

      expect(find.byKey(meetOfflineButtonKey), findsOneWidget);

      await tester.tap(find.byKey(meetOfflineButtonKey));
      await tester.pumpAndSettle();
    });
  });

  group('Not admin user who has invitation', () {

    testWidgets('displays meeting title, description, information, participants', (WidgetTester tester) async {

      when(mockAuthController.userId).thenReturn('3');

      await tester.pumpWidget(MaterialApp(
        home: MeetingDetailsPage(meeting: mockMeetingDetails2),
      ));

      expect(find.text(DataProvider.meetingTitle1), findsOneWidget);
      expect(find.text(DataProvider.meetingDescr1), findsOneWidget);

      expect(find.text(
          mockMeetingDetails2.getFormattedDate(DataProvider.dateTimeFutureObj)),
          findsOneWidget);
      expect(find.text(
          mockMeetingDetails2.getFormattedTime(DataProvider.dateTimeFutureObj)),
          findsOneWidget);
      expect(find.text(DataProvider.groupName1), findsOneWidget);
      expect(find.text(DataProvider.usernameAdmin), findsExactly(2));

      expect(find.byKey(linkPlaceholderFieldKey), findsNothing);
      expect(find.text(DataProvider.meetingLink), findsNothing);

      expect(find.byKey(meetOfflineButtonKey), findsNothing);
      expect(find.byKey(meetingAgendaButtonKey), findsNothing);
      expect(find.byKey(finishMeetingButtonKey), findsNothing);
      expect(find.byKey(summaryButtonKey), findsNothing);
      expect(find.byKey(answerButtonsKey), findsOneWidget);
      expect(find.byKey(attendMeetingButtonKey), findsNothing);
      expect(find.byKey(invitationDeclinedButtonKey), findsNothing);

      expect(find.text("Participants"), findsOneWidget);

      expect(find.text(DataProvider.username1), findsOneWidget);
      expect(find.text(DataProvider.username2), findsOneWidget);
      expect(find.text('accepted'), findsExactly(2));
      expect(find.text('needs_acceptance'), findsOneWidget);

      expect(find.text('Delete Meeting'), findsNothing);
    });

    testWidgets('clicks on accept meeting invitation', (WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      when(mockAuthController.userId).thenReturn('3');
      when(mockMeetingController.answerInvitation(true, mockMeetingDetails2.id))
          .thenAnswer((_) async => MeetingStatus.accepted);

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: MeetingDetailsPage(meeting: mockMeetingDetails2),
      ));

      expect(find.byKey(answerButtonsKey), findsOneWidget);
      expect(find.text("Accept"), findsOneWidget);

      // Click on accept meeting button and then NO
      await tester.tap(find.text("Accept"));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Meeting accepted'), findsOneWidget);

      verify(mockMeetingController.answerInvitation(true, mockMeetingDetails2.id)).called(1);
    });

    testWidgets('clicks on decline meeting invitation', (WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      when(mockAuthController.userId).thenReturn('3');
      when(mockMeetingController.answerInvitation(false, '12345'))
          .thenAnswer((_) async => MeetingStatus.declined);

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: MeetingDetailsPage(meeting: mockMeetingDetails2),
      ));

      expect(find.byKey(answerButtonsKey), findsOneWidget);
      expect(find.text("Decline"), findsOneWidget);

      // Click on accept meeting button and then NO
      await tester.tap(find.text("Decline"));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Meeting declined'), findsOneWidget);

      verify(mockMeetingController.answerInvitation(false, mockMeetingDetails2.id)).called(1);
    });

    testWidgets('clicks on accept meeting invitation of the past meeting', (WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      when(mockAuthController.userId).thenReturn('3');

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: MeetingDetailsPage(meeting: mockMeetingDetails6),
      ));

      expect(find.byKey(answerButtonsKey), findsOneWidget);
      expect(find.text("Accept"), findsOneWidget);

      // Click on accept meeting button and then NO
      await tester.tap(find.text("Accept"));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Meeting is in the past'), findsOneWidget);

      verifyNever(mockMeetingController.answerInvitation(true, mockMeetingDetails6.id));
    });

    testWidgets('clicks on accept meeting invitation of the finished meeting', (WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      when(mockAuthController.userId).thenReturn('3');

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: MeetingDetailsPage(meeting: mockMeetingDetails7),
      ));

      expect(find.byKey(answerButtonsKey), findsOneWidget);
      expect(find.text("Accept"), findsOneWidget);

      // Click on accept meeting button and then NO
      await tester.tap(find.text("Accept"));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Meeting is already finished'), findsOneWidget);

      verifyNever(mockMeetingController.answerInvitation(true, mockMeetingDetails7.id));
    });
  });

  group('Admin user', () {

    testWidgets('displays meeting title, description, information, participants', (WidgetTester tester) async {

      when(mockAuthController.userId).thenReturn('1');

      await tester.pumpWidget(MaterialApp(
        home: MeetingDetailsPage(meeting: mockMeetingDetails3),
      ));

      expect(find.text(DataProvider.meetingTitle1), findsOneWidget);
      expect(find.text(DataProvider.meetingDescr1), findsOneWidget);

      expect(find.text(
          mockMeetingDetails3.getFormattedDate(DataProvider.dateTimeFutureObj)),
          findsOneWidget);
      expect(find.text(
          mockMeetingDetails3.getFormattedTime(DataProvider.dateTimeFutureObj)),
          findsOneWidget);
      expect(find.text(DataProvider.groupName1), findsOneWidget);
      expect(find.text(DataProvider.usernameAdmin), findsExactly(2));

      expect(find.byKey(linkPlaceholderFieldKey), findsOneWidget);
      expect(find.text(DataProvider.meetingLink), findsOneWidget);

      expect(find.byKey(meetOfflineButtonKey), findsOneWidget);
      expect(find.byKey(meetingAgendaButtonKey), findsOneWidget);
      expect(find.byKey(finishMeetingButtonKey), findsOneWidget);
      expect(find.byKey(summaryButtonKey), findsNothing);
      expect(find.byKey(answerButtonsKey), findsNothing);
      expect(find.byKey(attendMeetingButtonKey), findsNothing);
      expect(find.byKey(invitationDeclinedButtonKey), findsNothing);

      expect(find.text("Participants"), findsOneWidget);

      expect(find.text(DataProvider.username1), findsOneWidget);
      expect(find.text(DataProvider.username2), findsOneWidget);
      expect(find.text('accepted'), findsExactly(2));
      expect(find.text('needs_acceptance'), findsOneWidget);

      expect(find.text('Delete Meeting'), findsOneWidget);
    });

    testWidgets('change meeting link (onSubmitted)', (WidgetTester tester) async {
      const newLink = 'https://www.google.com';
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
      when(mockAuthController.userId).thenReturn('1');
      when(mockMeetingController.updateMeetingLink(mockMeetingDetails3.id, newLink)).thenAnswer((_) async => {});

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: MeetingDetailsPage(meeting: mockMeetingDetails3),
      ));

      expect(find.byKey(linkPlaceholderFieldKey), findsOneWidget);
      expect(find.text(DataProvider.meetingLink), findsOneWidget);
      // Verify enabled border color

      final textField = tester.widget<TextField>(find.byType(TextField));
      final enabledBorder = textField.decoration!.enabledBorder as UnderlineInputBorder;
      expect(enabledBorder.borderSide.color, alphaDarkBlue);

      await tester.tap(find.byKey(linkPlaceholderFieldKey));
      await tester.enterText(find.byKey(linkPlaceholderFieldKey), newLink);
      await tester.pumpAndSettle();
      final focusedBorder = textField.decoration!.focusedBorder as UnderlineInputBorder;
      expect(focusedBorder.borderSide.color, darkBlue);
      expect(find.text(newLink), findsOneWidget);

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text(newLink), findsOneWidget);

      verify(mockMeetingController.updateMeetingLink(mockMeetingDetails3.id, newLink)).called(1);
    });

    testWidgets('change meeting link (onTapOutside)', (WidgetTester tester) async {
      const newLink = 'https://www.facebook.com';
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
      when(mockAuthController.userId).thenReturn('1');
      when(mockMeetingController.updateMeetingLink(mockMeetingDetails3.id, newLink)).thenAnswer((_) async => {});

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: MeetingDetailsPage(meeting: mockMeetingDetails3),
      ));

      expect(find.byKey(linkPlaceholderFieldKey), findsOneWidget);
      expect(find.text(DataProvider.meetingLink), findsOneWidget);

      final textField = tester.widget<TextField>(find.byType(TextField));
      final enabledBorder = textField.decoration!.enabledBorder as UnderlineInputBorder;
      expect(enabledBorder.borderSide.color, alphaDarkBlue);

      await tester.tap(find.byKey(linkPlaceholderFieldKey));
      await tester.enterText(find.byKey(linkPlaceholderFieldKey), newLink);
      await tester.pumpAndSettle();
      final focusedBorder = textField.decoration!.focusedBorder as UnderlineInputBorder;
      expect(focusedBorder.borderSide.color, darkBlue);
      expect(find.text(newLink), findsOneWidget);

      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      verify(mockMeetingController.updateMeetingLink(mockMeetingDetails3.id, newLink)).called(1);
    });

    testWidgets('copy and share meeting link ', (WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
      when(mockAuthController.userId).thenReturn('1');

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: MeetingDetailsPage(meeting: mockMeetingDetails3),
      ));

      expect(find.byKey(linkPlaceholderFieldKey), findsOneWidget);
      expect(find.text(DataProvider.meetingLink), findsOneWidget);

      await tester.tap(find.byKey(copyButtonKey));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Copied to clipboard'), findsOneWidget);

      await tester.tap(find.byKey(shareButtonKey));
      await tester.pumpAndSettle();
      // expect(find.text("Copy"), findsOneWidget);
      // TODO: test share button
    });

    testWidgets('delete meeting', (WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
      when(mockAuthController.userId).thenReturn('1');
      when(mockMeetingController.deleteMeeting(mockMeetingDetails3.id, null)).thenAnswer((_) async => {});

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: MeetingDetailsPage(meeting: mockMeetingDetails3),
      ));

      await tester.ensureVisible(find.text('Delete Meeting'));

      await tester.tap(find.text('Delete Meeting'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomPopUpDialog), findsOneWidget);
      await tester.tap(find.byKey(noButtonKey));
      await tester.pumpAndSettle();
      expect(find.byType(CustomPopUpDialog), findsNothing);

      await tester.tap(find.text('Delete Meeting'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomPopUpDialog), findsOneWidget);
      await tester.tap(find.byKey(yesButtonKey));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Meeting is deleted'), findsOneWidget);
    });

    testWidgets('fail to finish meeting', (WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
      when(mockAuthController.userId).thenReturn('1');
      when(mockMeetingController.finishMeeting(mockMeetingDetails3.id)).thenAnswer((_) async => false);

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: MeetingDetailsPage(meeting: mockMeetingDetails3),
      ));

      final finishMeetingButton = find.byKey(finishMeetingButtonKey);

      await tester.tap(finishMeetingButton);
      await tester.pumpAndSettle();
      expect(find.byType(CustomPopUpDialog), findsOneWidget);
      expect(find.text("Do you want to finish the meeting?"), findsOneWidget);
      await tester.tap(find.byKey(noButtonKey));
      await tester.pumpAndSettle();
      expect(find.byType(CustomPopUpDialog), findsNothing);

      await tester.tap(finishMeetingButton);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(yesButtonKey));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Failed to finish meeting'), findsOneWidget);

      verify(mockMeetingController.finishMeeting(mockMeetingDetails3.id)).called(1);
    });

  });

  group('Not admin user who declined future invitation', () {

    testWidgets(
        'displays meeting title, description, information, participants', (
        WidgetTester tester) async {

      when(mockAuthController.userId).thenReturn('3');

      await tester.pumpWidget(MaterialApp(
        home: MeetingDetailsPage(meeting: mockMeetingDetails4),
      ));

      expect(find.text(DataProvider.meetingTitle1), findsOneWidget);
      expect(find.text(DataProvider.meetingDescr1), findsOneWidget);

      expect(find.text(
          mockMeetingDetails4.getFormattedDate(DataProvider.dateTimeFutureObj)),
          findsOneWidget);
      expect(find.text(
          mockMeetingDetails4.getFormattedTime(DataProvider.dateTimeFutureObj)),
          findsOneWidget);
      expect(find.text(DataProvider.groupName1), findsOneWidget);
      expect(find.text(DataProvider.usernameAdmin), findsExactly(2));

      expect(find.byKey(linkPlaceholderFieldKey), findsNothing);
      expect(find.text(DataProvider.meetingLink), findsNothing);

      expect(find.byKey(meetOfflineButtonKey), findsNothing);
      expect(find.byKey(meetingAgendaButtonKey), findsNothing);
      expect(find.byKey(finishMeetingButtonKey), findsNothing);
      expect(find.byKey(summaryButtonKey), findsNothing);
      expect(find.byKey(answerButtonsKey), findsNothing);
      expect(find.byKey(attendMeetingButtonKey), findsOneWidget);
      expect(find.byKey(invitationDeclinedButtonKey), findsNothing);

      expect(find.text("Participants"), findsOneWidget);

      expect(find.text(DataProvider.username1), findsOneWidget);
      expect(find.text(DataProvider.username2), findsOneWidget);
      expect(find.text('accepted'), findsExactly(2));
      expect(find.text('declined'), findsOneWidget);

      expect(find.text('Delete Meeting'), findsNothing);
    });

    testWidgets(
        'clicks on attend meeting and snack bar shows', (
        WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      when(mockAuthController.userId).thenReturn('3');
      when(mockMeetingController.answerInvitation(true, '12345'))
          .thenAnswer((_) async => MeetingStatus.accepted);

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: MeetingDetailsPage(meeting: mockMeetingDetails4),
      ));

      expect(find.byKey(attendMeetingButtonKey), findsOneWidget);

      // Click on attend meeting button and then NO
      await tester.tap(find.byKey(attendMeetingButtonKey));
      await tester.pumpAndSettle();
      expect(find.byKey(alertDialogKey), findsOneWidget);
      expect(find.text('Do you want to attend the meeting?'), findsOneWidget);
      await tester.tap(find.byKey(noButtonKey));
      await tester.pumpAndSettle();
      expect(find.byKey(alertDialogKey), findsNothing);
      expect(find.byKey(attendMeetingButtonKey), findsOneWidget);

      // Click on attend meeting button and then YES
      await tester.tap(find.byKey(attendMeetingButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(yesButtonKey));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Meeting accepted'), findsOneWidget);
    });

  });

  group('Not admin user who declined and meeting is finished', () {

    testWidgets(
        'displays meeting title, description, information, participants', (
        WidgetTester tester) async {

      when(mockAuthController.userId).thenReturn('3');

      await tester.pumpWidget(MaterialApp(
        home: MeetingDetailsPage(meeting: mockMeetingDetails5),
      ));

      expect(find.text(DataProvider.meetingTitle1), findsOneWidget);
      expect(find.text(DataProvider.meetingDescr1), findsOneWidget);

      expect(find.text(
          mockMeetingDetails5.getFormattedDate(DataProvider.dateTimeFutureObj)),
          findsOneWidget);
      expect(find.text(
          mockMeetingDetails5.getFormattedTime(DataProvider.dateTimeFutureObj)),
          findsOneWidget);
      expect(find.text(DataProvider.groupName1), findsOneWidget);
      expect(find.text(DataProvider.usernameAdmin), findsExactly(2));

      expect(find.byKey(linkPlaceholderFieldKey), findsNothing);
      expect(find.text(DataProvider.meetingLink), findsNothing);

      expect(find.byKey(meetOfflineButtonKey), findsNothing);
      expect(find.byKey(meetingAgendaButtonKey), findsNothing);
      expect(find.byKey(finishMeetingButtonKey), findsNothing);
      expect(find.byKey(summaryButtonKey), findsNothing);
      expect(find.byKey(answerButtonsKey), findsNothing);
      expect(find.byKey(attendMeetingButtonKey), findsNothing);
      expect(find.byKey(invitationDeclinedButtonKey), findsOneWidget);

      expect(find.text("Participants"), findsOneWidget);

      expect(find.text(DataProvider.username1), findsOneWidget);
      expect(find.text(DataProvider.username2), findsOneWidget);
      expect(find.text('accepted'), findsExactly(2));
      expect(find.text('declined'), findsOneWidget);

      expect(find.text('Delete Meeting'), findsNothing);
    });

    testWidgets(
        'clicks on invitation declined and snack bar shows', (
        WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      when(mockAuthController.userId).thenReturn('3');

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: MeetingDetailsPage(meeting: mockMeetingDetails5),
      ));

      expect(find.byKey(invitationDeclinedButtonKey), findsOneWidget);

      await tester.tap(find.byKey(invitationDeclinedButtonKey));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Meeting is finished'), findsOneWidget);
    });

  });

}
