import 'dart:convert';
import 'package:coordimate/models/time_slot.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/pages/schedule_page.dart';

class ScheduleController {
  String scheduleUrl = '';
  String pageTitle = 'Schedule';
  bool isModifiable = false;
  bool canCreateMeeting = false;

  Future<List<TimeSlot>> getTimeSlots() async {
    var url = Uri.parse(scheduleUrl);
    final response =
    await AppState.client.get(url, headers: {"Content-Type": "application/json"});
    final List body = json.decode(response.body)['time_slots'];
    return body.map((e) => TimeSlot.fromJson(e)).toList();
  }

  Future<void> createTimeSlot(int day, double start, double length) async {
    if (!isModifiable) {
      return;
    }
    await AppState.client.post(Uri.parse(scheduleUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(<String, dynamic>{
          'is_meeting': false,
          'day': day,
          'start': start.toStringAsFixed(2),
          'length': length.toStringAsFixed(2)
        }));
  }

  Future<void> deleteTimeSlot(String id) async {
    if (!isModifiable) {
      return;
    }
    await AppState.client.delete(Uri.parse("$apiUrl/time_slots/$id"),
        headers: {"Content-Type": "application/json"});
  }

  Future<void> updateTimeSlot(String id, double start, double length) async {
    if (!isModifiable) {
      return;
    }
    await AppState.client.patch(Uri.parse("$apiUrl/time_slots/$id"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(<String, dynamic>{
          'id': id,
          'start': start.toStringAsFixed(2),
          'length': length.toStringAsFixed(2)
        }));
  }

  Future<SchedulePage?> tryParseUserScheduleLink(Uri uri) async {
    final regex = RegExp(r'^/users/([0-9a-z]+)/time_slots$');
    final match = regex.firstMatch(uri.path);
    if (match != null) {
      final userId = match.group(1)!;
      final response = await AppState.client.get(Uri.parse("$apiUrl/users/$userId"));
      if (response.statusCode != 200) {
        throw Exception('Failed to parse user schedule link');
      }
      return SchedulePage(ownerId: userId, ownerName: json.decode(response.body)["username"]);
    }
    return null;
  }

  Future<Group?> tryParseGroupJoinLink(Uri uri) async {
    final regex = RegExp(r'^/groups/([0-9a-z]+)/join$');
    final match = regex.firstMatch(uri.path);
    if (match != null) {
      final groupId = match.group(1)!;
      final response = await AppState.client.get(Uri.parse("$apiUrl/groups/$groupId"));
      if (response.statusCode != 200) {
        throw Exception('Failed to parse group join link');
      }
      return Group.fromJson(json.decode(response.body));
    }
    return null;
  }
}