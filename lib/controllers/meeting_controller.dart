import 'dart:developer';
import 'dart:convert';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/models/agenda_point.dart';

class MeetingController {
  Future<MeetingDetails> fetchMeetingDetails(id) async {
    final response =
        await AppState.client.get(Uri.parse("$apiUrl/meetings/$id/details"));
    if (response.statusCode == 200) {
      final meetingDetails =
          MeetingDetails.fromJson(json.decode(response.body));
      return meetingDetails;
    } else {
      throw Exception('Failed to load meetings');
    }
  }

  Future<String> fetchMeetingSummary(id) async {
    final response =
        await AppState.client.get(Uri.parse("$apiUrl/meetings/$id/details"));
    if (response.statusCode == 200) {
      final summary =
          MeetingDetails.fromJson(json.decode(response.body)).summary;
      return summary;
    } else {
      throw Exception('Failed to load meeting summary');
    }
  }

  Future<bool> finishMeeting(id) async {
    final response =
        await AppState.client.patch(Uri.parse("$apiUrl/meetings/$id"),
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
    final response =
        await AppState.client.patch(Uri.parse("$apiUrl/invites/$id"),
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

  Future<List<MeetingTileModel>> fetchArchivedMeetings() async {
    final response = await AppState.client.get(Uri.parse("$apiUrl/meetings"));
    if (response.statusCode == 200) {
      final meetings = (json.decode(response.body)['meetings'] as List)
          .map((data) => MeetingTileModel.fromJson(data))
          .where((meeting) =>
              meeting.status == MeetingStatus.declined ||
              meeting.isFinished ||
              meeting.isInPast())
          .toList();
      meetings.sort((a, b) =>
          a.dateTime.difference(DateTime.now()).inSeconds.abs() -
          b.dateTime.difference(DateTime.now()).inSeconds.abs());
      return meetings;
    } else {
      throw Exception('Failed to load declined meetings');
    }
  }

  Future<void> saveSummary(id, summaryText) async {
    final response =
        await AppState.client.patch(Uri.parse("$apiUrl/meetings/$id"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(<String, dynamic>{
              'summary': summaryText,
            }));
    if (response.statusCode != 200) {
      throw Exception('Failed to save summary');
    }
  }

  Future<List<AgendaPoint>> getAgendaPoints(id) async {
    final response = await AppState.client.get(
        Uri.parse("$apiUrl/meetings/$id/agenda"),
        headers: {"Content-Type": "application/json"});
    final List body = json.decode(response.body)["agenda"];
    final agenda = body.map((e) => AgendaPoint.fromJson(e)).toList();
    return agenda;
  }

  Future<void> createAgendaPoint(id, String text, int level) async {
    await AppState.client.post(Uri.parse("$apiUrl/meetings/$id/agenda"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(<String, dynamic>{
          'text': text,
          'level': level,
        }));
  }

  Future<void> deleteAgendaPoint(id, int index) async {
    await AppState.client.delete(
        Uri.parse("$apiUrl/meetings/$id/agenda/$index"),
        headers: {"Content-Type": "application/json"});
  }

  Future<void> updateAgenda(id, agenda) async {
    await AppState.client.patch(Uri.parse("$apiUrl/meetings/$id/agenda"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(<String, dynamic>{
          'agenda':
              agenda.map((ap) => {'text': ap.text, 'level': ap.level}).toList(),
        }));
  }

  Future<List<MeetingTileModel>> fetchMeetings() async {
    final response = await AppState.client.get(Uri.parse("$apiUrl/meetings"));
    if (response.statusCode != 200) {
      throw Exception('Failed to load meetings');
    }
    final meetings = (json.decode(response.body)['meetings'] as List)
        .map((data) => MeetingTileModel.fromJson(data))
        .toList();
    for (var meeting in meetings
        .where((meeting) => !meeting.isFinished && meeting.isInPast())
        .toList()) {
      finishMeeting(meeting.id);
    }
    for (var meeting in meetings
        .where((meeting) =>
            meeting.status == MeetingStatus.needsAcceptance &&
            (meeting.isInPast() || meeting.isFinished))
        .toList()) {
      answerInvitation(false, meeting.id);
    }
    meetings.sort((a, b) =>
        a.dateTime.difference(DateTime.now()).inSeconds.abs() -
        b.dateTime.difference(DateTime.now()).inSeconds.abs());
    return meetings;
  }

  Future<void> createMeeting(String title, String start, int length,
      String description, String groupId) async {
    String? meetingLink;
    if (AppState.authController.calApi != null) {
      var eventData = await AppState.googleCalendarClient.insert(
        title: title,
        description: description,
        startTime: DateTime.parse(start),
        duration: length,
        hasConferenceSupport: true,
        shouldNotifyAttendees: true,
      );
      if (eventData.containsKey('link')) meetingLink = eventData['link'];
    } else {
      log('User not signed in to google, not creating a google meet');
    }

    var body = <String, dynamic>{
      'title': title,
      'start': DateTime.parse(start).toUtc().toString(),
      'length': length,
      'description': description,
      'group_id': groupId,
    };
    if (meetingLink != null) {
      body['meeting_link'] = meetingLink;
    }
    final response = await AppState.client.post(
      Uri.parse("$apiUrl/meetings"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create meeting');
    }
  }
}
