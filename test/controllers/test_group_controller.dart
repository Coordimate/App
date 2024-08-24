import 'package:coordimate/app_state.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_group_controller.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage, SharedPreferences])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GroupController Tests', () {
    late MockClient client;

    setUp(() {
      client = MockClient();
      AppState.client = client;
    });

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
                   "admin": {"id": "admin_id"},
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

      expect(group.poll!.votes.containsKey(0), true);
      expect(group.poll!.votes.containsKey(1), true);
      expect(group.poll!.votes[0]![0], 'user_1_id');
      expect(group.poll!.votes[0]![1], 'user_2_id');
      expect(group.poll!.votes[1]![0], 'user_3_id');

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
      // TODO: duration should be stored on the backend
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
  });
}
