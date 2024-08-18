import 'package:coordimate/app_state.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_meeting_controller.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage, SharedPreferences])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MeetingController Tests', () {
    late MockClient client;

    setUp(() {
      client = MockClient();
      AppState.client = client;
    });

    test('Empty list response if no meetings are available', () async {
      when(client.get(Uri.parse("$apiUrl/meetings")))
          .thenAnswer((_) async => http.Response('{"meetings": []}', 200));
      final meetings = await AppState.meetingController.fetchMeetings();
      expect(meetings, []);
    });

    test('Non-successful API response code throws an exception', () async {
      when(client.get(Uri.parse("$apiUrl/meetings")))
          .thenAnswer((_) async => http.Response('', 500));
      expect(() async {
        await AppState.meetingController.fetchMeetings();
      }, throwsException);
    });

    test('Creates meeting', () async {
      when(client.post(Uri.parse("$apiUrl/meetings"),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: anyNamed('body')))
          .thenAnswer((request) async {
        expect(
            request.namedArguments[const Symbol("body")],
            '{"title":"Title",'
            '"start":"2024-07-09T13:10:00.00",'
            '"description":"Description",'
            '"group_id":"1"'
            '}');
        return http.Response('', 201);
      });
      await AppState.meetingController.createMeeting(
          "Title", "2024-07-09T13:10:00.00", 60, "Description", "1");
    });

    test('Gets information about meeting from fetchMeetings', () async {
      when(client.get(Uri.parse("$apiUrl/meetings")))
          .thenAnswer((_) async => http.Response('''{
                                "meetings": [
                                  {
                                    "id": "1",
                                    "title": "meeting",
                                    "start": "2024-07-09T13:10:00.000",
                                    "length": 60,
                                    "group": {
                                      "id": "1",
                                      "name": "group"
                                      },
                                    "status": "accepted",
                                    "is_finished": true
                                  }
                                ]
                              }''', 200));
      final meetings = await AppState.meetingController.fetchMeetings();
      expect(meetings.length, 1);
      expect(meetings[0].id, '1');
      expect(meetings[0].title, 'meeting');
      expect(meetings[0].isFinished, true);
      expect(meetings[0].status, MeetingStatus.accepted);
      expect(meetings[0].dateTime, DateTime.parse("2024-07-09T13:10:00.000"));
      expect(meetings[0].group.id, '1');
      expect(meetings[0].group.name, 'group');
      expect(meetings[0].duration, 60);
    });
  });
}
