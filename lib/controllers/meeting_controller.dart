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
    print("here");
    if (response.statusCode == 200) {
      final summary = MeetingDetails.fromJson(json.decode(response.body)).summary;
      print("return");
      return summary;
    } else {
      throw Exception('Failed to load meeting summary');
    }
  }
}