import 'dart:convert';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/models/agenda_point.dart';


class MeetingController {

  Future<MeetingDetails> fetchMeetingDetails(id) async {
    final response = await AppState.authController.client.get(Uri.parse("$apiUrl/meetings/$id/details"));
    if (response.statusCode == 200) {
      final meetingDetails = MeetingDetails.fromJson(json.decode(response.body));
      return meetingDetails;
    } else {
      throw Exception('Failed to load meetings');
    }
  }

  Future<String> fetchMeetingSummary(id) async {
    final response = await AppState.authController.client
        .get(Uri.parse("$apiUrl/meetings/$id/details"));
    if (response.statusCode == 200) {
      final summary = MeetingDetails.fromJson(json.decode(response.body)).summary;
      return summary;
    } else {
      throw Exception('Failed to load meeting summary');
    }
  }

  Future<bool> finishMeeting(id) async {
    final response = await AppState.authController.client.patch(Uri.parse("$apiUrl/meetings/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, dynamic>{
          'is_finished': true,
        }));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to finish meeting');
    }
  }

  Future<MeetingStatus> answerInvitation(bool accept, id) async {
    final status = accept ? 'accepted' : 'declined';
    final response = await AppState.authController.client.patch(Uri.parse("$apiUrl/invites/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, dynamic>{
          'status': status,
        }));
    if (response.statusCode == 200) {
      return accept ? MeetingStatus.accepted : MeetingStatus.declined;
    } else {
      throw Exception('Failed to answer invitation');
    }
  }

  Future<List<MeetingTileModel>> fetchDeclinedMeetings() async {
    final response = await AppState.authController.client.get(Uri.parse("$apiUrl/meetings/"));
    if (response.statusCode == 200) {
      final meetings = (json.decode(response.body)['meetings'] as List)
            .map((data) => MeetingTileModel.fromJson(data))
            .where((meeting) =>
        meeting.status == MeetingStatus.declined ||
            (meeting.status == MeetingStatus.accepted &&
                meeting.dateTime.isBefore(DateTime.now())))
            .toList();
        meetings.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return meetings;
    } else {
      throw Exception('Failed to load declined meetings');
    }
  }

  Future<void> saveSummary(id, summaryText) async {
    final response = await AppState.authController.client.patch(
        Uri.parse("$apiUrl/meetings/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, dynamic>{
          'summary': summaryText,
        })
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to save summary');
    }
  }

  Future<List<AgendaPoint>> getAgendaPoints(id) async {
    final response = await AppState.authController.client.get(
        Uri.parse("$apiUrl/meetings/$id/agenda"),
        headers: {"Content-Type": "application/json"});
    final List body = json.decode(response.body)["agenda"];
    final agenda = body.map((e) => AgendaPoint.fromJson(e)).toList();
    return agenda;
  }

  Future<void> createAgendaPoint(id, String text, int level) async {
    await AppState.authController.client.post(Uri.parse("$apiUrl/meetings/$id/agenda"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(<String, dynamic>{
          'text': text,
          'level': level,
        }));
  }

  Future<void> deleteAgendaPoint(id, int index) async {
    await AppState.authController.client.delete(
        Uri.parse("$apiUrl/meetings/$id/agenda/$index"),
        headers: {"Content-Type": "application/json"});
  }

  Future<void> updateAgenda(id, agenda) async {
    await AppState.authController.client.patch(Uri.parse("$apiUrl/meetings/$id/agenda"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(<String, dynamic>{
          'agenda':
          agenda.map((ap) => {'text': ap.text, 'level': ap.level}).toList(),
        }));
  }

  Future<List<MeetingTileModel>> fetchMeetings() async {
    final response = await AppState.authController.client.get(Uri.parse("$apiUrl/meetings"));
    if (response.statusCode != 200) {
      throw Exception('Failed to load meetings');
    }
    final meetings = (json.decode(response.body)['meetings'] as List)
        .map((data) => MeetingTileModel.fromJson(data))
        .toList();
    for (var meeting in meetings
        .where((meeting) => meeting.status == MeetingStatus.needsAcceptance)
        .toList()) {
      if (meeting.dateTime.isBefore(DateTime.now())) {
        answerInvitation(false, meeting.id);
      }
    }
    meetings.sort((a, b) =>
      a.dateTime.difference(DateTime.now()).inSeconds.abs() -
        b.dateTime.difference(DateTime.now()).inSeconds.abs());
    return meetings;
  }
}