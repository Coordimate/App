import 'dart:convert';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/pages/schedule_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import '../helpers/client/users.dart';
import '../test.mocks.dart';
import '../helpers/response.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScheduleController Tests', () {
    late MockClient client;

    setUp(() {
      client = MockClient();
      AppState.client = client;
      AppState.scheduleController.isModifiable = true;
      AppState.scheduleController.scheduleUrl =
          '$apiUrl/users/user_id/schedule';
    });

    test('Empty list response if no time slots are available', () async {
      getResponse(client, '/users/user_id/schedule', '{"time_slots": []}');
      final timeSlots = await AppState.scheduleController.getTimeSlots();
      expect(timeSlots, []);
    });

    test('Time slot parsed if one time slot is returned', () async {
      getResponse(client, '/users/user_id/schedule',
          '{"time_slots": [{"id": "id", "day": 2, "start":"2024-08-27 15:35:54.176446Z", "length":50, "is_meeting": false}]}');
      final timeSlots = await AppState.scheduleController.getTimeSlots();
      expect(timeSlots.length, 1);
      expect(timeSlots[0].id, 'id');
      expect(timeSlots[0].day, 2);
      expect(timeSlots[0].length, 0.8333333333333334);
      expect(timeSlots[0].isMeeting, false);
      final dt = DateTime.parse("2024-08-27 15:35:54.176446Z").toLocal();
      expect(timeSlots[0].start, dt.hour + dt.minute / 60);
    });

    test('Cant create time slot when schedule not modifiable', () async {
      AppState.scheduleController.isModifiable = false;
      await AppState.scheduleController.createTimeSlot(0, 0.0, 0.0);
      verifyNever(client.post(Uri.parse('$apiUrl/users/user_id/schedule'),
          headers: anyNamed('headers'), body: anyNamed('body')));
    });

    test('Time slots are sent to the API as UTC strings', () async {
      postResponse(client, '/users/user_id/schedule', '');

      await AppState.scheduleController.createTimeSlot(0, 0.0, 0.0);

      final now = DateTime.now();
      verify(client.post(Uri.parse('$apiUrl/users/user_id/schedule'),
          headers: anyNamed('headers'),
          body: json.encode(<String, dynamic>{
            'is_meeting': false,
            'day': 0,
            'start': DateTime(now.year, now.month, now.day).toUtc().toString(),
            'length': 0,
          }))).called(1);
    });

    test('Cant delete time slot when schedule not modifiable', () async {
      AppState.scheduleController.isModifiable = false;
      await AppState.scheduleController.deleteTimeSlot('id');
      verifyNever(client.delete(Uri.parse('$apiUrl/time_slots/id'),
          headers: anyNamed('headers'), body: anyNamed('body')));
    });

    test('API delete time slot called on deleteTimeSlot', () async {
      deleteResponse(client, '/time_slots/id', '');
      await AppState.scheduleController.deleteTimeSlot('id');
      verify(client.delete(Uri.parse('$apiUrl/time_slots/id'),
              headers: anyNamed('headers'), body: anyNamed('body')))
          .called(1);
    });

    test('Cant update time slot when schedule not modifiable', () async {
      AppState.scheduleController.isModifiable = false;
      await AppState.scheduleController.updateTimeSlot('id', 0, 0);
      verifyNever(client.patch(Uri.parse('$apiUrl/time_slots/id'),
          headers: anyNamed('headers'), body: anyNamed('body')));
    });

    test('Bad patch time slot response throws exception', () async {
      patchResponse(client, '/time_slots/id', '', statusCode: 500);
      expect(
          () async =>
              await AppState.scheduleController.updateTimeSlot('id', 0, 0),
          throwsException);
    });

    // FIXME: the actual call doesn't match the verify call
    // test('Time slot updates are sent to the API as UTC strings', () async {
    //   patchResponse(client, '/time_slots/id', '');
    //
    //   await AppState.scheduleController.updateTimeSlot('id', 0.0, 0.0);
    //
    //   final now = DateTime.now();
    //   verify(client.patch(Uri.parse('$apiUrl/times_slots/id'), headers: anyNamed('headers'), body:
    //   json.encode(<String, dynamic>{
    //     'is_meeting': false,
    //     'start': DateTime(now.year, now.month, now.day).toUtc().toString(),
    //     'length': 0,
    //   }))).called(1);
    // });

    test('Bad user schedule link returns null', () async {
      final res = await AppState.scheduleController
          .tryParseUserScheduleLink(Uri.parse('bad'));
      expect(res, isNull);
    });

    test('Bad group join link returns null', () async {
      final res = await AppState.scheduleController
          .tryParseGroupJoinLink(Uri.parse('bad'));
      expect(res, isNull);
    });

    test('Link to non-existing user throws exception', () async {
      getResponse(client, '/users/bad', '', statusCode: 404);
      expect(() async => await AppState.scheduleController
          .tryParseUserScheduleLink(Uri.parse('/users/bad/time_slots')), throwsException);
    });

    test('Link to non-existing group throws exception', () async {
      getResponse(client, '/groups/bad', '', statusCode: 404);
      expect(() async => await AppState.scheduleController
          .tryParseGroupJoinLink(Uri.parse('/groups/bad/join')), throwsException);
    });

    test('Good link to user schedule returns SchedulePage', () async {
      whenUserDetails(client);
      final res = await AppState.scheduleController
          .tryParseUserScheduleLink(Uri.parse('/users/userid/time_slots'));
      verify(client.get(Uri.parse('$apiUrl/users/userid'), headers: anyNamed('headers'))).called(1);
      expect(res.toString(), const SchedulePage().toString());
    });

    test('Good link to join group returns GroupModel', () async {
      // NOTE: duplicating when statement here to use group id without underscores (like a proper ObjectId),
      // otherwise regex parsing breaks
      when(client.get(Uri.parse("$apiUrl/groups/groupid"),
          headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('''
            {
              "_id": "groupid",
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
      final res = await AppState.scheduleController
          .tryParseGroupJoinLink(Uri.parse('/groups/groupid/join'));
      expect(res.toString(), Group(id: 'groupid', name: 'name').toString());
    });
  });
}
