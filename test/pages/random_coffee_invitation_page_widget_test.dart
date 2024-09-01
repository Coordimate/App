import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/create_meeting_dialog.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/models/time_slot.dart';
import 'package:coordimate/models/user.dart';
import 'package:coordimate/pages/personal_info_page.dart';
import 'package:coordimate/pages/random_coffee_invitation_page.dart';
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
  late MockMeetingController mockMeetingController;

  const mockUserId = '12345';
  final mockUser = Participant(
      id: mockUserId, status: 'needs acceptance', username: 'user1');
  final mockOtherUser =
      Participant(id: 'user2', status: 'needs acceptance', username: 'user2');

  final mockMeetingDetails = MeetingDetails(
    id: '1',
    title: 'title',
    admin: mockOtherUser,
    description: 'description',
    dateTime: DateTime(2020, 10, 8, 4, 5, 6),
    groupId: 'group1',
    groupName: 'group',
    summary: 'summary',
    isFinished: false,
    duration: 60,
    participants: [mockUser, mockOtherUser],
    status: MeetingStatus.needsAcceptance,
  );

  setUp(() {
    mockAuthController = MockAuthorizationController();
    mockMeetingController = MockMeetingController();

    AppState.authController = mockAuthController;
    AppState.meetingController = mockMeetingController;
    AppState.testMode = true;

    when(mockAuthController.userId).thenAnswer((_) => mockUserId);
    when(mockMeetingController.answerInvitation(any, any))
        .thenAnswer((_) async => MeetingStatus.accepted);
  });

  group('Random Coffee Invitation Page', () {
    testWidgets('displays widgets', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: RandomCoffeeInvitationPage(meeting: mockMeetingDetails),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Time to grab some coffee!'), findsOne);
      expect(find.text('With user2'), findsOne);
      expect(find.text('October'), findsOne);
      expect(find.text('8'), findsOne);
      expect(find.text('04:05'), findsOne);
      expect(find.byKey(randomCoffeeAcceptKey), findsOne);
      expect(find.byKey(randomCoffeeDeclineKey), findsOne);
    });

    testWidgets('thumbs up accepts the meeting', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: RandomCoffeeInvitationPage(meeting: mockMeetingDetails),
      ));

      await tester.pumpAndSettle();

      expect(find.byKey(randomCoffeeAcceptKey), findsOne);
      await tester.tap(find.byKey(randomCoffeeAcceptKey));
      await tester.pumpAndSettle();

      verify(mockMeetingController.answerInvitation(true, mockMeetingDetails.id)).called(1);
    });

    testWidgets('thumbs down declines the meeting', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: RandomCoffeeInvitationPage(meeting: mockMeetingDetails),
      ));

      await tester.pumpAndSettle();

      expect(find.byKey(randomCoffeeDeclineKey), findsOne);
      await tester.tap(find.byKey(randomCoffeeDeclineKey));
      await tester.pumpAndSettle();

      verify(mockMeetingController.answerInvitation(false, mockMeetingDetails.id)).called(1);
    });
  });
}
