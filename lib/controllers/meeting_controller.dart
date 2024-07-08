import 'dart:convert';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/api_client.dart';
import 'package:coordimate/keys.dart';


class MeetingController {

  Future<MeetingDetails> fetchMeetingDetails(id) async {
    final response = await client.get(Uri.parse("$apiUrl/meetings/$id/details"));
    if (response.statusCode == 200) {
      final meetingDetails = MeetingDetails.fromJson(json.decode(response.body));
      return meetingDetails;
    } else {
      throw Exception('Failed to load meetings');
    }
  }

  Future<String> fetchMeetingSummary(id) async {
    final response = await client
        .get(Uri.parse("$apiUrl/meetings/$id/details"));
    if (response.statusCode == 200) {
      final summary = MeetingDetails.fromJson(json.decode(response.body)).summary;
      return summary;
    } else {
      throw Exception('Failed to load meeting summary');
    }
  }

  Future<bool> finishMeeting(id) async {
    final response = await client.patch(Uri.parse("$apiUrl/meetings/$id"),
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
    final response = await client.patch(Uri.parse("$apiUrl/invites/$id"),
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
    final response = await client.get(Uri.parse("$apiUrl/meetings/"));
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
}