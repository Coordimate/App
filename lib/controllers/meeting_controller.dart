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
    // if (widget.meeting.isFinished) {
    //   CustomSnackBar.show(context, "Meeting is already finished");
    //   return;
    // }
    final response = await client.patch(Uri.parse("$apiUrl/meetings/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, dynamic>{
          'is_finished': true,
        }));
    if (response.statusCode == 200) {
      // CustomSnackBar.show(context, "Meeting is finished");
      // setState(() {
      //   widget.meeting.isFinished = true;
      // });
      return true;
    } else {
      throw Exception('Failed to finish meeting');
    }
  }
}