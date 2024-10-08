import 'dart:convert';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/models/agenda_point.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import '../helpers/response.dart';
import '../test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MeetingController Tests', () {
    late MockClient client;
    const id = '1';

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
                '"start":"${DateTime.parse("2024-07-09 13:10:00.00").toUtc().toString()}",'
                '"length":60,'
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
          .thenAnswer((_) async =>
          http.Response('''{
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
                                  },
                                  {
                                    "id": "2",
                                    "title": "meeting",
                                    "start": "2024-08-09T13:10:00.000",
                                    "length": 60,
                                    "group": {
                                      "id": "1",
                                      "name": "group"
                                      },
                                    "status": "declined",
                                    "is_finished": true
                                  }
                                ]
                              }''', 200));
      final meetings = await AppState.meetingController.fetchMeetings();
      expect(meetings.length, 2);
      expect(meetings[1].id, '1');
      expect(meetings[1].title, 'meeting');
      expect(meetings[1].isFinished, true);
      expect(meetings[1].status, MeetingStatus.accepted);
      expect(meetings[1].dateTime, DateTime.parse("2024-07-09T13:10:00.000"));
      expect(meetings[1].group.id, '1');
      expect(meetings[1].group.name, 'group');
      expect(meetings[1].duration, 60);
    });

    test('fetchMeetingDetails returns info on success', () async {
      getResponse(client, '/meetings/$id/details', '''{
                                    "id": "$id",
                                    "title": "meeting title",
                                    "start": "2024-07-09T13:10:00.000",
                                    "length": 20,
                                    "is_finished": true,
                                    "description": "string of description",
                                    "summary": "string for summary",
                                    "group_id": "id_gr",
                                    "group_name": "name of group",
                                    "admin": {
                                      "user_id": "adminID",
                                      "user_username": "admin username here",
                                      "status": "accepted"
                                    },
                                    "participants": [],
                                    "meeting_link": "meeting_link",
                                    "google_event_id": "google_event_id",
                                    "status": "accepted"
                                  }''');
      final meeting = await AppState.meetingController.fetchMeetingDetails(id);

      expect(meeting.id, id);
      expect(meeting.title, 'meeting title');
      expect(meeting.dateTime, DateTime.parse('2024-07-09T13:10:00.000'));
      expect(meeting.duration, 20);
      expect(meeting.isFinished, true);
      expect(meeting.description, 'string of description');
      expect(meeting.summary, 'string for summary');
      expect(meeting.groupId, 'id_gr');
      expect(meeting.groupName, 'name of group');
      expect(meeting.admin.id, 'adminID');
      expect(meeting.admin.username, 'admin username here');
      expect(meeting.admin.status, 'accepted');
      expect(meeting.participants, []);
      expect(meeting.meetingLink, 'meeting_link');
      expect(meeting.googleEventId, 'google_event_id');
      expect(meeting.status, MeetingStatus.accepted);
    });

    test('fetchMeetingDetails throws an exception on failure', () async {
      getResponse(client, '/meetings/$id/details', '{"error": "not found"}',
          statusCode: 404);

      expect(() => AppState.meetingController.fetchMeetingDetails(id), throwsException);
    });

    test('fetchMeetingSummary returns summary on success', () async {
      getResponse(client, '/meetings/$id/details', '''{
                                    "id": "$id",
                                    "title": "string",
                                    "start": "2024-07-09T13:10:00.000",
                                    "length": 0,
                                    "is_finished": true,
                                    "description": "string",
                                    "summary": "Summary A",
                                    "group_id": "string",
                                    "group_name": "string",
                                    "admin": {
                                      "user_id": "string",
                                      "user_username": "string",
                                      "status": "string"
                                    },
                                    "participants": [],
                                    "meeting_link": "string",
                                    "google_event_id": "string",
                                    "status": "string"
                                  }''');
      final summary = await AppState.meetingController.fetchMeetingSummary(id);

      expect(summary, 'Summary A');
    });

    test('fetchMeetingSummary throws an exception on failure', () async {
      getResponse(client, '/meetings/$id/details', '{"error": "not found"}',
          statusCode: 404);

      expect(() => AppState.meetingController.fetchMeetingSummary(id), throwsException);
    });

    test('finishMeeting returns true on success', () async {
      patchResponse(client, '/meetings/$id', '{}');

      final result = await AppState.meetingController.finishMeeting(id);

      expect(result, true);
    });

    test('finishMeeting throws an exception on failure', () async {
      patchResponse(
          client, '/meetings/$id', '{"error": "not found"}', statusCode: 404);

      expect(() => AppState.meetingController.finishMeeting(id), throwsException);
    });

    test('answerInvitation returns accepted status on success', () async {
      patchResponse(client, '/invites/$id', '{}', statusCode: 200);

      final status = await AppState.meetingController.answerInvitation(true, id);

      expect(status, MeetingStatus.accepted);
    });

    test('answerInvitation returns declined status on success', () async {
      patchResponse(client, '/invites/$id', '{}', statusCode: 200);

      final status = await AppState.meetingController.answerInvitation(false, id);

      expect(status, MeetingStatus.declined);
    });

    test('answerInvitation throws an exception on failure', () async {
      patchResponse(
          client, '/invites/$id', '{"error": "not found"}', statusCode: 404);

      expect(() => AppState.meetingController.answerInvitation(true, id),
          throwsException);
    });

    test(
        'fetchArchivedMeetings returns list of MeetingTileModel on success', () async {
      getResponse(client, '/meetings', '''{
                                "meetings": [
                                  {
                                    "id": "1",
                                    "title": "Archived Meeting",
                                    "start": "2024-07-09T13:10:00.000",
                                    "length": 60,
                                    "group": {
                                      "id": "1",
                                      "name": "group"
                                      },
                                    "status": "accepted",
                                    "is_finished": true,
                                    "summary": "Summary A"
                                  },
                                  {
                                    "id": "2",
                                    "title": "meeting",
                                    "start": "2600-07-09T13:10:00.000",
                                    "length": 60,
                                    "group": {
                                      "id": "1",
                                      "name": "group"
                                      },
                                    "status": "accepted",
                                    "is_finished": false,
                                    "summary": "Summary A"
                                  },
                                  {
                                    "id": "3",
                                    "title": "Archived Meeting",
                                    "start": "2024-08-09T13:10:00.000",
                                    "length": 60,
                                    "group": {
                                      "id": "1",
                                      "name": "group"
                                      },
                                    "status": "declined",
                                    "is_finished": true,
                                    "summary": "Summary A"
                                  }
                                ]
                              }''');

      final meetings = await AppState.meetingController.fetchArchivedMeetings();

      expect(meetings.length, 2);
      expect(meetings.first.title, 'Archived Meeting');
    });

    test('fetchArchivedMeetings throws an exception on failure', () async {
      getResponse(
          client, '/meetings', '{"error": "not found"}', statusCode: 404);

      expect(() => AppState.meetingController.fetchArchivedMeetings(), throwsException);
    });

    test('saveSummary saves the summary on success', () async {
      patchResponse(client, '/meetings/$id', '{}');

      await AppState.meetingController.saveSummary(id, 'Meeting Summary');

      // Check if the patch was done correctly
      verify(client.patch(any, headers: anyNamed('headers'),
          body: json.encode({'summary': 'Meeting Summary'}))).called(1);
    });

    test('saveSummary throws an exception on failure', () async {
      patchResponse(
          client, '/meetings/$id', '{"error": "not found"}', statusCode: 404);

      expect(() => AppState.meetingController.saveSummary(id, 'Meeting Summary'),
          throwsException);
    });

    test('getAgendaPoints returns list of AgendaPoint on success', () async {
      getResponse(client, '/meetings/$id/agenda',
          '{"agenda": [{"text": "Agenda Point 1", "level": 1}]}');

      final agendaPoints = await AppState.meetingController.getAgendaPoints(id);

      expect(agendaPoints.length, 1);
      expect(agendaPoints.first.text, 'Agenda Point 1');
    });

    test('createAgendaPoint successful call', () async {
      postResponse(client, '/meetings/$id/agenda', 'ok');

      await AppState.meetingController.createAgendaPoint(id, 'New Agenda', 1);

      verify(client.post(Uri.parse('$apiUrl/meetings/$id/agenda'), headers: anyNamed('headers'),
          body: json.encode({'text': 'New Agenda', 'level': 1}))).called(1);
    });

    test('deleteAgendaPoint successful call', () async {
      const index = 0;
      deleteResponse(client, '/meetings/$id/agenda/$index', 'ok');

      await AppState.meetingController.deleteAgendaPoint(id, index);

      verify(client.delete(Uri.parse('$apiUrl/meetings/$id/agenda/$index'), headers: anyNamed('headers'))).called(1);
    });

    test('updateAgenda successful call', () async {
      final agenda = [AgendaPoint(text: 'Point 1', level: 1)];
      patchResponse(client, '/meetings/$id/agenda', '');

      await AppState.meetingController.updateAgenda(id, agenda);

      verify(client.patch(Uri.parse('$apiUrl/meetings/$id/agenda'), headers: anyNamed('headers'),
          body: json.encode({'agenda': [{'text': 'Point 1', 'level': 1}]})))
          .called(1);
    });

    test('createMeeting successfully creates a meeting', () async {
      postResponse(client, '/meetings', '{"id": "1"}', statusCode: 201);

      await AppState.meetingController.createMeeting(
          'Meeting Title',
          '2022-07-09T13:10:00',
          60,
          'Meeting Description',
          '1'
      );

      verify(client.post(Uri.parse("$apiUrl/meetings"), headers: anyNamed('headers'), body: anyNamed('body'))).called(
          1);
    });

    test('createMeeting throws an exception on failure', () async {
      postResponse(
          client, '/meetings', '{"error": "not found"}', statusCode: 404);

      expect(() =>
          AppState.meetingController.createMeeting(
              'Meeting Title',
              '2022-07-09T13:10:00',
              60,
              'Meeting Description',
              '1'
          ), throwsException);
    });

    test('updateMeetingTime successfully updates meeting time', () async {
      patchResponse(client, '/meetings/$id', '{}');

      await AppState.meetingController.updateMeetingTime(
          id, '2022-07-09T14:10:00', 60, null);

      verify(client.patch(Uri.parse('$apiUrl/meetings/$id'), headers: anyNamed('headers'), body: anyNamed('body'))).called(
          1);
    });

    test('updateMeetingTime throws an exception on failure', () async {
      patchResponse(
          client, '/meetings/$id', '{"error": "not found"}', statusCode: 404);

      expect(() =>
          AppState.meetingController.updateMeetingTime(
              id, '2022-07-09T14:10:00', 60, null), throwsException);
    });

    test('deleteMeeting successfully deletes a meeting', () async {
      deleteResponse(client, '/meetings/$id', '', statusCode: 204);

      await AppState.meetingController.deleteMeeting(id, null);

      verify(client.delete(Uri.parse("$apiUrl/meetings/$id"), headers: anyNamed('headers'))).called(1);
    });

    test('deleteMeeting throws an exception on failure', () async {
      deleteResponse(
          client, '/meetings/$id', '{"error": "not found"}', statusCode: 404);

      expect(() => AppState.meetingController.deleteMeeting(id, null), throwsException);
    });

    test('suggestMeetingLocation successfully suggests a location', () async {
      postResponse(client, '/meetings/$id/suggest_location',
          '{"link": "http://suggested.location"}', statusCode: 200);

      final link = await AppState.meetingController.suggestMeetingLocation(id);

      expect(link, 'http://suggested.location');
    });

    test('suggestMeetingLocation throws an exception on failure', () async {
      postResponse(
          client, '/meetings/$id/suggest_location', '{"error": "not found"}',
          statusCode: 404);

      expect(() => AppState.meetingController.suggestMeetingLocation(id),
          throwsException);
    });

    group('updateMeetingLink', () {
      test('successfully updates the meeting link', () async {
        const meetingId = '1';
        const meetingLink = 'http://new.meeting.link';

        when(AppState.client.patch(
          Uri.parse('$apiUrl/meetings/$meetingId'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('{}', 200));

        await AppState.meetingController.updateMeetingLink(meetingId, meetingLink);

        verify(AppState.client.patch(
          Uri.parse('$apiUrl/meetings/$meetingId'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({'meeting_link': meetingLink}),
        )).called(1);
      });

      test('does not update if link is empty', () async {
        const meetingId = '1';
        const meetingLink = '';

        await AppState.meetingController.updateMeetingLink(meetingId, meetingLink);

        verifyNever(AppState.client.patch(
          Uri.parse('$apiUrl/meetings/$meetingId'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({'meeting_link': meetingLink}),
        ));
      });

      test('does not update if link is filled with spaces', () async {
        const meetingId = '1';
        const meetingLink = '   ';

        await AppState.meetingController.updateMeetingLink(meetingId, meetingLink);

        verifyNever(AppState.client.patch(
          Uri.parse('$apiUrl/meetings/$meetingId'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({'meeting_link': meetingLink}),
        ));
      });

      test('throws an exception on failure', () async {
        const meetingId = '1';
        const meetingLink = 'http://new.meeting.link';

        when(AppState.client.patch(
          Uri.parse('$apiUrl/meetings/$meetingId'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Not Found', 404));

        expect(
              () => AppState.meetingController.updateMeetingLink(meetingId, meetingLink),
          throwsException,
        );
      });
    });
  });
}
