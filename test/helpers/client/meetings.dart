import 'package:coordimate/keys.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

void whenMeetingsNone(client) {
  when(client.get(
    Uri.parse('$apiUrl/meetings'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"meetings": []}', 200));
}

const acceptedInTheFuture = '{"id": "1", "title": "acceptedInTheFuture ","start": "2025-07-09T13:10:00.000","group": {"id": "2","name": "group"},"status": "accepted","is_finished": false}';
const acceptedInThePast = '{"id": "2", "title": "acceptedInThePast ","start": "2020-07-09T13:10:00.000","group": {"id": "2","name": "group"},"status": "accepted","is_finished": true}';
const declinedInTheFuture = '{"id": "3", "title": "declinedInTheFuture ","start": "2025-07-09T13:10:00.000","group": {"id": "2","name": "group"},"status": "declined","is_finished": false}';
const declinedInThePast = '{"id": "4", "title": "declinedInThePast ","start": "2020-07-09T13:10:00.000","group": {"id": "2","name": "group"},"status": "declined","is_finished": true}';
const invitationInTheFuture = '{"id": "5", "title": "invitationInTheFuture ","start": "2025-07-09T13:10:00.000","group": {"id": "2","name": "group"},"status": "invitation","is_finished": false}';


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
