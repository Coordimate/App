import 'package:coordimate/app_state.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import '../helpers/response.dart';
import '../test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockClient client;
  client = MockClient();
  AppState.client = client;

  test('Empty list response if no groups are available', () async {
    when(client.get(Uri.parse("$apiUrl/groups")))
        .thenAnswer((_) async => http.Response('{"groups": []}', 200));
    final groups = await AppState.groupController.getGroups();
    expect(groups, []);
  });

  test('Non-successful API response code throws an exception', () async {
    when(client.get(Uri.parse("$apiUrl/groups")))
        .thenAnswer((_) async => http.Response('', 500));
    expect(() async {
      await AppState.groupController.getGroups();
    }, throwsException);
  });

  test('Group poll data parsed correctly', () async {
    when(client.get(Uri.parse("$apiUrl/groups/group_id")))
        .thenAnswer((_) async => http.Response('''{
                   "id": "group_id",
                   "name": "name",
                   "admin": {"_id": "admin_id"},
                   "decscription": "description",
                   "poll": {
                     "question": "question",
                     "options": ["one", "two"],
                     "votes": {"0": ["user_1_id", "user_2_id"], "1": ["user_3_id"]}
                   }
                 }''', 200));
    final group = await AppState.groupController.getGroup("group_id");
    expect(group.poll, isNotNull);
    expect(group.poll!.question, 'question');
    expect(group.poll!.options[0], 'one');
    expect(group.poll!.options[1], 'two');

    expect(group.poll!.votes, isNotNull);
    expect(group.poll!.votes!.containsKey(0), true);
    expect(group.poll!.votes!.containsKey(1), true);
    expect(group.poll!.votes![0]![0], 'user_1_id');
    expect(group.poll!.votes![0]![1], 'user_2_id');
    expect(group.poll!.votes![1]![0], 'user_3_id');

    expect(group.adminId, 'admin_id');
  });

  test('Create group passes name and description of the group to the API',
      () async {
    when(client.post(Uri.parse("$apiUrl/groups"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: anyNamed('body')))
        .thenAnswer((request) async {
      expect(request.namedArguments[const Symbol("body")],
          '{"name":"group","description":"description"}');
      return http.Response('', 201);
    });
    await AppState.groupController.createGroup("group", "description");
  });

  test('Only id, name and description are parsed for each group in getGroups',
      () async {
    when(client.get(Uri.parse("$apiUrl/groups")))
        .thenAnswer((_) async => http.Response('''{
                                "groups": [
                                  {
                                    "id": "group_id",
                                    "admin": {
                                      "_id": "admin_id",
                                      "username": "admin"
                                    },
                                    "name": "name",
                                    "description": "description",
                                    "users": [],
                                    "meetings": [],
                                    "schedule": []
                                  }
                                ]
                              }''', 200));
    final groups = await AppState.groupController.getGroups();
    expect(groups.length, 1);
    expect(groups[0].id, 'group_id');
    expect(groups[0].name, 'name');
    expect(groups[0].description, 'description');
  });

  test('Meetings Tiles are correctly parsed from group meetings response',
      () async {
    when(client.get(Uri.parse("$apiUrl/groups/1/meetings")))
        .thenAnswer((_) async => http.Response('''{
                                "meetings": [
                                  {
                                    "id": "meeting_id",
                                    "title": "meeting",
                                    "start": "2022-01-01T12:00:00",
                                    "group": {
                                      "_id": "group_id",
                                      "name": "group"
                                    },
                                    "status": "accepted",
                                    "is_finished": false
                                  }
                                ]
                              }''', 200));
    final meetingTiles = await AppState.groupController.fetchGroupMeetings(1);
    expect(meetingTiles.length, 1);
    expect(meetingTiles[0].id, 'meeting_id');
    expect(meetingTiles[0].title, 'meeting');
    expect(meetingTiles[0].status, MeetingStatus.accepted);
    expect(meetingTiles[0].isFinished, false);
    expect(meetingTiles[0].dateTime, DateTime(2022, 1, 1, 12, 0, 0));
    expect(meetingTiles[0].duration, 60);
  });

  test('Group invite link is returned form the API', () async {
    when(client.get(Uri.parse("$apiUrl/groups/1/invite"),
            headers: {"Content-Type": "application/json"}))
        .thenAnswer((_) async =>
            http.Response('{ "join_link": "http://google.com" }', 200));
    final inviteLink = await AppState.groupController.shareInviteLink(1);
    expect(inviteLink, "http://google.com");
  });

  group('joinGroup tests', () {
    test('Sends POST request to the correct URL', () async {
      when(client.post(Uri.parse("$apiUrl/groups/group_id/join"),
              headers: {"Content-Type": "application/json"}))
          .thenAnswer((_) async => http.Response('', 200));
      when(client.get(Uri.parse("$apiUrl/groups/group_id")))
          .thenAnswer((_) async => http.Response('''{
                   "id": "group_id",
                   "name": "name",
                   "admin": {"_id": "admin_id"},
                   "description": "description"
                 }''', 200));

      await AppState.groupController.joinGroup("group_id");

      verify(client.post(Uri.parse("$apiUrl/groups/group_id/join"),
          headers: {"Content-Type": "application/json"})).called(1);
    });

    test('Correctly parses group data from response', () async {
      when(client.post(Uri.parse("$apiUrl/groups/group_id/join"),
              headers: {"Content-Type": "application/json"}))
          .thenAnswer((_) async => http.Response('', 200));
      when(client.get(Uri.parse("$apiUrl/groups/group_id")))
          .thenAnswer((_) async => http.Response('''{
                   "id": "group_id",
                   "name": "group_name",
                   "admin": {"_id": "admin_id"},
                   "description": "description"
                 }''', 200));

      final group = await AppState.groupController.joinGroup("group_id");

      expect(group.id, "group_id");
      expect(group.name, "group_name");
    });

    test('Throws exception when response status code is not 200 in post',
        () async {
      when(client.post(Uri.parse("$apiUrl/groups/group_id/join"),
              headers: {"Content-Type": "application/json"}))
          .thenAnswer((_) async => http.Response('', 500));

      expect(() async {
        await AppState.groupController.joinGroup("group_id");
      }, throwsException);
    });

    test('Throws exception when response status code is not 200 in get',
        () async {
      when(client.post(Uri.parse("$apiUrl/groups/group_id/join"),
              headers: {"Content-Type": "application/json"}))
          .thenAnswer((_) async => http.Response('', 200));
      when(client.get(Uri.parse("$apiUrl/groups/group_id")))
          .thenAnswer((_) async => http.Response('', 500));

      expect(() async {
        await AppState.groupController.joinGroup("group_id");
      }, throwsException);
    });
  });

  test('Fetches groups successfully', () async {
    getResponse(client, '/groups',
        '{"groups": [{"id": "group1", "admin": {"id": "admin_id"}, "name": "Test Group", "description": "A group for testing"}]}');
    final groups = await AppState.groupController.getGroups();
    expect(groups.length, 1);
    expect(groups[0].id, 'group1');
    expect(groups[0].name, 'Test Group');
  });

  test('Fetches group by id successfully', () async {
    getResponse(client, '/groups/group1',
        '{"id": "group1", "admin": {"id": "admin_id"}, "name": "Test Group", "description": "A group for testing"}');
    final group = await AppState.groupController.getGroup('group1');
    expect(group.id, 'group1');
    expect(group.name, 'Test Group');
  });

  test('Throws exception when fetching group fails', () async {
    getResponse(client, '/groups/group1', '', statusCode: 404);
    expect(() async => await AppState.groupController.getGroup('group1'),
        throwsException);
  });

  test('Creates a group successfully', () async {
    postResponse(client, '/groups', '', statusCode: 201);
    await AppState.groupController
        .createGroup('New Group', 'Description of new group');
    verify(client.post(Uri.parse('$apiUrl/groups'),
            headers: anyNamed('headers'), body: anyNamed('body')))
        .called(2);
  });

  test('Throws exception when creating group fails', () async {
    postResponse(client, '/groups', '', statusCode: 400);
    expect(
        () async => await AppState.groupController
            .createGroup('New Group', 'Description of new group'),
        throwsException);
  });

  test('Fetches group meetings successfully', () async {
    getResponse(client, '/groups/group1/meetings', '{"meetings": []}');
    final meetings =
        await AppState.groupController.fetchGroupMeetings('group1');
    expect(meetings, []);
  });

  test('Throws exception when fetching group meetings fails', () async {
    getResponse(client, '/groups/group1/meetings', '', statusCode: 404);
    expect(
        () async => await AppState.groupController.fetchGroupMeetings('group1'),
        throwsException);
  });

  test('Updates group description successfully', () async {
    patchResponse(client, '/groups/group1', '', statusCode: 200);
    await AppState.groupController
        .updateGroupDescription('group1', 'New Description');
    verify(client.patch(Uri.parse('$apiUrl/groups/group1'),
            headers: anyNamed('headers'), body: anyNamed('body')))
        .called(1);
  });

  test('Throws exception when updating group description fails', () async {
    patchResponse(client, '/groups/group1', '', statusCode: 500);
    expect(
        () async => await AppState.groupController
            .updateGroupDescription('group1', 'New Description'),
        throwsException);
  });

  test('Deletes a group successfully', () async {
    deleteResponse(client, '/groups/group1', '', statusCode: 204);
    await AppState.groupController.deleteGroup('group1');
    verify(client.delete(Uri.parse('$apiUrl/groups/group1'),
            headers: anyNamed('headers')))
        .called(1);
  });

  test('Throws exception when deleting group fails', () async {
    deleteResponse(client, '/groups/group1', '', statusCode: 500);
    expect(() async => await AppState.groupController.deleteGroup('group1'),
        throwsException);
  });

  test('Leaves a group successfully', () async {
    postResponse(client, '/groups/group1/leave', '', statusCode: 200);
    await AppState.groupController.leaveGroup('group1');
    verify(client.post(Uri.parse('$apiUrl/groups/group1/leave'),
            headers: anyNamed('headers')))
        .called(1);
  });

  test('Throws exception when leaving group fails', () async {
    postResponse(client, '/groups/group1/leave', '', statusCode: 500);
    expect(() async => await AppState.groupController.leaveGroup('group1'),
        throwsException);
  });

  test('Fetches group users successfully', () async {
    getResponse(client, '/groups/group1', '{"users": []}');
    final users = await AppState.groupController.fetchGroupUsers('group1');
    expect(users, []);
  });

  test('Throws exception when fetching group users fails', () async {
    getResponse(client, '/groups/group1', '', statusCode: 404);
    expect(() async => await AppState.groupController.fetchGroupUsers('group1'),
        throwsException);
  });

  test('Fetches group chat messages successfully', () async {
    getResponse(client, '/groups/group1', '{"chat_messages": "[]"}');
    final messages =
        await AppState.groupController.fetchGroupChatMessages('group1');
    expect(messages, []);
  });

  test('Throws exception when fetching group chat messages fails', () async {
    getResponse(client, '/groups/group1', '', statusCode: 404);
    expect(
        () async =>
            await AppState.groupController.fetchGroupChatMessages('group1'),
        throwsException);
  });

  test('Shares invite link successfully', () async {
    getResponse(client, '/groups/group1/invite',
        '{"join_link": "http://example.com/join"}');
    final link = await AppState.groupController.shareInviteLink('group1');
    expect(link, 'http://example.com/join');
  });

  test('Throws exception when sharing invite link fails', () async {
    getResponse(client, '/groups/group1/invite', '', statusCode: 500);
    expect(() async => await AppState.groupController.shareInviteLink('group1'),
        throwsException);
  });

  test('Joins a group successfully', () async {
    postResponse(client, '/groups/group1/join', '', statusCode: 200);
    getResponse(client, '/groups/group1',
        '{"id": "group1", "admin": {"id": "admin_id"}, "description": "", "name": "Test Group"}');
    final group = await AppState.groupController.joinGroup('group1');
    expect(group.id, 'group1');
    expect(group.name, 'Test Group');
  });

  test('Throws exception when joining group fails', () async {
    postResponse(client, '/groups/group1/join', '', statusCode: 500);
    expect(() async => await AppState.groupController.joinGroup('group1'),
        throwsException);
  });

  const groupId = '123';
  const pollData =
      '{"question": "Your favorite color?", "options": ["Red", "Blue"]}';

  test('createPoll should succeed on valid response', () async {
    patchResponse(client, '/groups/$groupId', '{"poll": {"id": "1"}}',
        statusCode: 200);

    await AppState.groupController.createPoll(groupId, pollData);
    // verify that there was a patch request
    verify(client.patch(any,
        headers: anyNamed('headers'), body: anyNamed('body')));
  });

  test('createPoll should throw exception on error response', () async {
    patchResponse(client, '/groups/$groupId', 'Error', statusCode: 400);

    expect(AppState.groupController.createPoll(groupId, pollData),
        throwsException);
  });

  test('fetchPoll should succeed and return a poll', () async {
    getResponse(client, '/groups/$groupId',
        '{"poll": {"id": "1", "question": "Favorite color?", "options": ["Red", "Blue"]}}',
        statusCode: 200);

    await AppState.groupController.fetchPoll(groupId);
    verify(client.get(any, headers: anyNamed('headers')));
  });

  test('fetchPoll should throw exception on error response', () async {
    getResponse(client, '/groups/$groupId', 'Error', statusCode: 404);

    expect(AppState.groupController.fetchPoll(groupId), throwsException);
  });

  test('deletePoll should succeed on valid response', () async {
    deleteResponse(client, '/groups/$groupId/poll', '', statusCode: 200);

    await AppState.groupController.deletePoll(groupId);
    verify(client.delete(any, headers: anyNamed('headers')));
  });

  test('deletePoll should throw exception on error response', () async {
    deleteResponse(client, '/groups/$groupId/poll', 'Error', statusCode: 400);

    expect(AppState.groupController.deletePoll(groupId), throwsException);
  });

  test('voteOnPoll should succeed on valid response', () async {
    postResponse(client, '/groups/$groupId/poll/0', '', statusCode: 200);

    await AppState.groupController.voteOnPoll(groupId, 0);
    verify(client.post(any, headers: anyNamed('headers')));
  });

  test('voteOnPoll should throw exception on error response', () async {
    postResponse(client, '/groups/$groupId/poll/0', 'Error', statusCode: 400);

    expect(AppState.groupController.voteOnPoll(groupId, 0), throwsException);
  });

  test('updateGroupMeetingLink should succeed on valid response', () async {
    patchResponse(client, '/groups/$groupId', '', statusCode: 200);

    await AppState.groupController
        .updateGroupMeetingLink(groupId, 'http://newmeetinglink.com');
    verify(client.patch(any,
        headers: anyNamed('headers'), body: anyNamed('body')));
  });

  test('updateGroupMeetingLink should throw exception on error response',
      () async {
    patchResponse(client, '/groups/$groupId', 'Error', statusCode: 400);

    expect(
        AppState.groupController
            .updateGroupMeetingLink(groupId, 'http://newmeetinglink.com'),
        throwsException);
  });

  test('updateGroupName should succeed on valid response', () async {
    patchResponse(client, '/groups/$groupId', '', statusCode: 200);

    await AppState.groupController.updateGroupName(groupId, 'name');
    verify(client.patch(any,
        headers: anyNamed('headers'), body: anyNamed('body')));
  });

  test('updateGroupName should throw exception on error response', () async {
    patchResponse(client, '/groups/$groupId', 'Error', statusCode: 400);

    expect(AppState.groupController.updateGroupName(groupId, 'name'),
        throwsException);
  });
}
