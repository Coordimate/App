import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/agenda.dart';
import 'package:coordimate/controllers/meeting_controller.dart';
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/pages/meeting_info_page.dart';
import 'package:coordimate/pages/meeting_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'helpers/client/data_provider.dart';
import 'meeting_info_page_widget_test.mocks.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks(
    [MeetingController, AuthorizationController])
void main() {
  late MeetingDetails mockMeetingDetails1;
  late MeetingDetails mockMeetingDetails2;
  late MeetingDetails mockMeetingDetails3;
  late MeetingDetails mockMeetingDetails4;
  late MeetingDetails mockMeetingDetails5;
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

      expect(find.byKey(appBarIconButtonKey), findsOneWidget);

      // Click on decline meeting button and then NO
      await tester.tap(find.byKey(appBarIconButtonKey));
      await tester.pumpAndSettle();
      expect(find.byKey(alertDialogKey), findsOneWidget);
      expect(find.text('Do you want to decline the invitation?'), findsOneWidget);
      await tester.tap(find.byKey(noButtonKey));
      await tester.pumpAndSettle();
      expect(find.byKey(alertDialogKey), findsNothing);
      expect(find.byKey(appBarIconButtonKey), findsOneWidget);

      // Click on attend meeting button and then YES
      await tester.tap(find.byKey(appBarIconButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(yesButtonKey));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Meeting declined'), findsOneWidget);
      expect(find.byKey(appBarIconButtonKey), findsNothing);
    });

    testWidgets('redirects to meeting agenda page', (WidgetTester tester) async {
      when(mockAuthController.userId).thenReturn('2');
      when(mockMeetingController.getAgendaPoints('12345')).thenAnswer((_) async => []);

      await tester.pumpWidget(MaterialApp(
        home: MeetingDetailsPage(meeting: mockMeetingDetails1),
      ));

      expect(find.byKey(meetingAgendaButtonKey), findsOneWidget);

      await tester.tap(find.byKey(meetingAgendaButtonKey));
      await tester.pumpAndSettle();

      expect(find.byType(MeetingAgenda), findsOneWidget);

      expect(find.text('Agenda'), findsOneWidget);
    });

    testWidgets('finish meeting and redirect to summary page', (WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
      when(mockAuthController.userId).thenReturn('2');
      when(mockMeetingController.fetchMeetingSummary('12345')).thenAnswer((_) async => '');
      when(mockMeetingController.finishMeeting('12345')).thenAnswer((_) async => true);

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: MeetingDetailsPage(meeting: mockMeetingDetails1),
      ));

      expect(find.byKey(finishMeetingButtonKey), findsOneWidget);
      await tester.tap(find.byKey(finishMeetingButtonKey));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Meeting is finished'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byKey(finishMeetingButtonKey), findsNothing);
      expect(find.byKey(summaryButtonKey), findsOneWidget);
      await tester.tap(find.byKey(summaryButtonKey));
      await tester.pumpAndSettle();
      expect(find.byType(SummaryPage), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);
    });

    testWidgets('opens maps for offline meeting', (WidgetTester tester) async {
      when(mockAuthController.userId).thenReturn('2');
      when(mockMeetingController.suggestMeetingLocation('12345'))
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

    testWidgets(
        'displays meeting title, description, information, participants', (
        WidgetTester tester) async {

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
      when(mockMeetingController.answerInvitation(true, '12345'))
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

    testWidgets('change date and time for meeting', (WidgetTester tester) async {
    // TODO: implement test
    });

    testWidgets('change meeting link for meeting', (WidgetTester tester) async {
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
