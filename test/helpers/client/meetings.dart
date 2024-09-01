import 'package:coordimate/keys.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'data_provider.dart';

void whenMeetingsNone(client) {
  when(client.get(
    Uri.parse('$apiUrl/meetings'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"meetings": []}', 200));
}

const acceptedInTheFuture = '{"id": "1", "title": "acceptedInTheFuture ","start": "2025-07-09T13:10:00.000", "length": 60, "group": {"id": "2","name": "group"},"status": "accepted","is_finished": false}';
const acceptedInThePast = '{"id": "2", "title": "acceptedInThePast ","start": "2020-07-09T13:10:00.000", "length": 60,"group": {"id": "2","name": "group"},"status": "accepted","is_finished": true}';
const declinedInTheFuture = '{"id": "3", "title": "declinedInTheFuture ","start": "2025-07-09T13:10:00.000", "length": 60,"group": {"id": "2","name": "group"},"status": "declined","is_finished": false}';
const declinedInThePast = '{"id": "4", "title": "declinedInThePast ","start": "2020-07-09T13:10:00.000", "length": 60,"group": {"id": "2","name": "group"},"status": "declined","is_finished": true}';
const invitationInTheFuture = '{"id": "5", "title": "invitationInTheFuture ","start": "2025-07-09T13:10:00.000", "length": 60,"group": {"id": "2","name": "group"},"status": "invitation","is_finished": false}';


void whenMeetingsOneAcceptedInTheFuture(client) {
  when(client.get(
    Uri.parse('$apiUrl/meetings'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"meetings": [$acceptedInTheFuture]}', 200));
}

void whenMeetingsOneAcceptedInThePast(client) {
  when(client.get(
    Uri.parse('$apiUrl/meetings'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"meetings": [$acceptedInThePast]}', 200));
}

void whenMeetingsOneDeclinedInTheFuture(client) {
  when(client.get(
    Uri.parse('$apiUrl/meetings'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"meetings": [$declinedInTheFuture]}', 200));
}

void whenMeetingsOneDeclinedInThePast(client) {
  when(client.get(
    Uri.parse('$apiUrl/meetings'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"meetings": [$declinedInThePast]}', 200));
}

void whenMeetingsOneInvitationInTheFuture(client) {
  when(client.get(
    Uri.parse('$apiUrl/meetings'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"meetings": [$invitationInTheFuture]}', 200));
}

void whenMeetingsTwoAcceptedAndInvitationInTheFuture(client) {
  when(client.get(
    Uri.parse('$apiUrl/meetings'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"meetings": [$acceptedInTheFuture, $invitationInTheFuture]}', 200));
}

final groupCard1 = GroupCard(id: DataProvider.groupID1, name: DataProvider.groupName1);

final meetingTileInvitationFuture = MeetingTileModel(
    id: DataProvider.meetingID1,
    title: DataProvider.meetingTitle1,
    dateTime: DataProvider.dateTimeFutureObj,
    duration: 60,
    group: groupCard1,
    status: MeetingStatus.needsAcceptance,
    isFinished: false
);

final meetingTileInvitationTomorrow = MeetingTileModel(
    id: DataProvider.meetingID1,
    title: DataProvider.meetingTitle1,
    dateTime: DateTime.now().add(const Duration(days: 1)),
    duration: 60,
    group: groupCard1,
    status: MeetingStatus.needsAcceptance,
    isFinished: false
);

final meetingTileAcceptedTomorrow = MeetingTileModel(
    id: DataProvider.meetingID2,
    title: DataProvider.meetingTitle2,
    dateTime: DateTime.now().add(const Duration(days: 1)),
    duration: 60,
    group: groupCard1,
    status: MeetingStatus.accepted,
    isFinished: false
);

final meetingTileDeclinedTomorrow = MeetingTileModel(
    id: DataProvider.meetingID3,
    title: DataProvider.meetingTitle3,
    dateTime: DateTime.now().add(const Duration(days: 1)),
    duration: 60,
    group: groupCard1,
    status: MeetingStatus.declined,
    isFinished: false
);

final meetingTileAcceptedFuture = MeetingTileModel(
    id: DataProvider.meetingID1,
    title: DataProvider.meetingTitle1,
    dateTime: DataProvider.dateTimeFutureObj,
    duration: 60,
    group: groupCard1,
    status: MeetingStatus.accepted,
    isFinished: false
);

final meetingTileDeclinedFuture = MeetingTileModel(
    id: DataProvider.meetingID1,
    title: DataProvider.meetingTitle1,
    dateTime: DataProvider.dateTimeFutureObj,
    duration: 60,
    group: groupCard1,
    status: MeetingStatus.declined,
    isFinished: false
);

final meetingTileAcceptedPast = MeetingTileModel(
    id: DataProvider.meetingID2,
    title: DataProvider.meetingTitle2,
    dateTime: DataProvider.dateTimePastObj,
    duration: 60,
    group: groupCard1,
    status: MeetingStatus.accepted,
    isFinished: true
);

final meetingTileDeclinedPast = MeetingTileModel(
    id: DataProvider.meetingID3,
    title: DataProvider.meetingTitle3,
    dateTime: DataProvider.dateTimePastObj,
    duration: 60,
    group: groupCard1,
    status: MeetingStatus.declined,
    isFinished: true
);

final participantAccepted = Participant(
    id: '1acc',
    username: DataProvider.username1,
    status: "accepted"
);

final participantDeclined = Participant(
    id: '2dec',
    username: DataProvider.username2,
    status: "declined"
);

final participantPending = Participant(
    id: '3pen',
    username: DataProvider.username3,
    status: "needs_acceptance"
);

final meetingDetailsFutureAccepted = MeetingDetails(
    title: DataProvider.meetingTitle1,
    dateTime: DataProvider.dateTimeFutureObj,
    duration: 60,
    participants: [participantAccepted, participantDeclined, participantPending],
    description: DataProvider.meetingDescr1,
    admin: participantAccepted,
    groupId: DataProvider.groupID1,
    groupName: DataProvider.groupName1,
    status: MeetingStatus.accepted,
    isFinished: false,
    summary: '',
    meetingLink: DataProvider.meetingLink
);

final meetingDetailsFutureDeclined = MeetingDetails(
    title: DataProvider.meetingTitle1,
    dateTime: DataProvider.dateTimeFutureObj,
    duration: 60,
    participants: [participantAccepted, participantDeclined, participantPending],
    description: DataProvider.meetingDescr1,
    admin: participantAccepted,
    groupId: DataProvider.groupID1,
    groupName: DataProvider.groupName1,
    status: MeetingStatus.declined,
    isFinished: false,
    summary: '',
    meetingLink: DataProvider.meetingLink
);

final meetingDetailsFuturePending = MeetingDetails(
    title: DataProvider.meetingTitle1,
    dateTime: DataProvider.dateTimeFutureObj,
    duration: 60,
    participants: [participantAccepted, participantDeclined, participantPending],
    description: DataProvider.meetingDescr1,
    admin: participantAccepted,
    groupId: DataProvider.groupID1,
    groupName: DataProvider.groupName1,
    status: MeetingStatus.needsAcceptance,
    isFinished: false,
    summary: '',
    meetingLink: DataProvider.meetingLink
);

final meetingDetailsPastDeclined = MeetingDetails(
    title: DataProvider.meetingTitle1,
    dateTime: DataProvider.dateTimePastObj,
    duration: 60,
    participants: [participantAccepted, participantDeclined],
    description: DataProvider.meetingDescr1,
    admin: participantAccepted,
    groupId: DataProvider.groupID1,
    groupName: DataProvider.groupName1,
    status: MeetingStatus.declined,
    isFinished: true,
    summary: '',
    meetingLink: DataProvider.meetingLink
);

const meetingDetailsPastDeclinedJSON = '{"title": "meetingTitle1","dateTime": "2020-07-09T13:10:00.000","duration": 60,"participants": [{"id": "1acc","username": "username1","status": "accepted"},{"id": "2dec","username": "username2","status": "declined"}],"description": "meetingDescr1","admin": {"id": "1acc","username": "username1","status": "accepted"},"groupId": "1","groupName": "group1","status": "declined","isFinished": true,"summary": "","meetingLink": "meetingLink"}';
