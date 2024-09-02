import 'package:coordimate/keys.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/models/user.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'data_provider.dart';
import 'dart:convert';
import 'package:coordimate/models/meeting.dart';

String groupName1 = DataProvider.getGroupName1();
String groupName2 = DataProvider.getGroupName2();
String groupDescr1 = DataProvider.getGroupDescr1();
String groupDescr2 = DataProvider.getGroupDescr2();
String longGroupDescr = DataProvider.getLongGroupDescr();
String longGroupName = DataProvider.getLongGroupName();

final groupCard1 = {
  '"id": "group_id", "admin": {"_id": "admin_id", "username": "admin"}, "name": "$groupName1","description": "$groupDescr1","users": [],"meetings": [],"schedule": []'
};
final groupCard2 = {
  '"id": "group_id", "admin": {"_id": "admin_id", "username": "admin"}, "name": "$groupName2","description": "$groupDescr2","users": [],"meetings": [],"schedule": []'
};
final groupCard3 = {
  '"id": "group_id", "admin": {"_id": "admin_id", "username": "admin"}, "name": "$groupName1","description": "$longGroupDescr","users": [],"meetings": [],"schedule": []'
};
final groupCard4 = {
  '"id": "group_id", "admin": {"_id": "admin_id", "username": "admin"}, "name": "$longGroupName","description": "$longGroupDescr","users": [],"meetings": [],"schedule": []'
};

void whenGroupsNone(client) {
  when(client.get(
    Uri.parse('$apiUrl/groups'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"groups": []}', 200));
}

void whenGroupsOne(client) {
  when(client.get(
    Uri.parse('$apiUrl/groups'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"groups" : [$groupCard1]}', 200));
}

void whenGroupsTwo(client) {
  when(client.get(
    Uri.parse('$apiUrl/groups'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async =>
      http.Response('{"groups" : [$groupCard1, $groupCard2]}', 200));
}

void whenGroupsLongOne(client) {
  when(client.get(
    Uri.parse('$apiUrl/groups'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"groups" : [$groupCard3]}', 200));
}

void whenGroupsLongNameAndDescr(client) {
  when(client.get(
    Uri.parse('$apiUrl/groups'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"groups" : [$groupCard4]}', 200));
}

void whenCreateGroup(client) {
  when(client.post(
    Uri.parse('$apiUrl/groups'),
    headers: anyNamed('headers'),
    body: anyNamed('body'),
  )).thenAnswer((_) async => http.Response(
      '{"id": "group_id", "admin": {"_id": "admin_id", "username": "admin"}, "name": "$groupName1","description": "$groupDescr1","users": [],"meetings": [],"schedule": []}',
      201));
}

void whenGroupsDetails(client) {
  when(client.get(Uri.parse("$apiUrl/groups/group_id"),
          headers: anyNamed('headers')))
      .thenAnswer((_) async => http.Response('''
    {
      "_id": "group_id",
      "admin": {
        "_id": "admin_id",
        "username": "username"
      },
      "name": "name",
      "description": "description",
      "users": [{
        "id": "admin_id",
        "username": "username"
      }],
      "meetings": [],
      "schedule": [],
      "chat_messages": "[]"
    }
    ''', 200));
}

void whenGroupsMeetings(client) {
  when(client.get(Uri.parse("$apiUrl/groups/group_id/meetings"),
          headers: anyNamed('headers')))
      .thenAnswer((_) async => http.Response('{"meetings": []}', 200));
}

// new testing stuff

final userCard1 =
    UserCard(id: DataProvider.userAdmin, username: DataProvider.username1);

final userCard2 =
    UserCard(id: DataProvider.userID2, username: DataProvider.username2);

final inviteLink =
    DataProvider.inviteLink; //also possible to use directly from dataprovider

final pollData = GroupPoll(
  question: DataProvider.question,
  options: DataProvider.options,
  //votes: DataProvider.votes
);

final createPoll = json.encode({
  "question": DataProvider.question,
  "options": DataProvider.options,
});

final group1 = Group(
    id: DataProvider.groupID1,
    name: DataProvider.groupName1,
    description: DataProvider.groupDescr1,
    adminId: DataProvider.userAdmin,
    groupMeetingLink: DataProvider.groupMeetingLink);

final group2 = Group(
    id: DataProvider.groupID1,
    name: DataProvider.groupName1,
    adminId: DataProvider.userAdmin,
    groupMeetingLink: DataProvider.groupMeetingLink);

final groupMeetingCard1 =
    GroupCard(id: DataProvider.groupID1, name: DataProvider.groupName1);

final dateTimein2Days = DateTime.now().add(const Duration(days: 2));
final dateTimeArchived = DateTime.now().subtract(const Duration(days: 2));
final dateTimeFutureString = dateTimein2Days.toString();

const meetingAcceptedStatus = MeetingStatus.accepted;
const meetingRejectedStatus = MeetingStatus.declined;
const meetingPendingStatus = MeetingStatus.needsAcceptance;

final meetingin2Days = MeetingTileModel(
    id: DataProvider.meetingID1,
    title: DataProvider.meetingTitle1,
    group: groupMeetingCard1,
    dateTime: dateTimein2Days,
    duration: 20,
    status: meetingAcceptedStatus,
    isFinished: false);

final meetingArchived = MeetingTileModel(
    id: DataProvider.meetingID1,
    title: DataProvider.meetingTitle1,
    group: groupMeetingCard1,
    dateTime: dateTimeArchived,
    duration: 20,
    status: meetingRejectedStatus,
    isFinished: true);
