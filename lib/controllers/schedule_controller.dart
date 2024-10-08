import 'dart:developer';
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
  String ownerId = '';

  void setScheduleParams(scheduleUrl_, pageTitle_, isModifiable_, canCreateMeeting_) {
    scheduleUrl = scheduleUrl_;
    isModifiable = isModifiable_;
    pageTitle = pageTitle_;
    canCreateMeeting = canCreateMeeting_;
  }

  Future<List<TimeSlot>> getTimeSlots() async {
    var url = Uri.parse(scheduleUrl);
    final response = await AppState.client
        .get(url, headers: {"Content-Type": "application/json"});
    final List body = json.decode(response.body)['time_slots'];
    return body.map((e) => TimeSlot.fromJson(e)).toList();
  }

  Future<void> createTimeSlot(int day, double start, double length) async {
    if (!isModifiable) {
      return;
    }

    var now = DateTime.now();
    var weekStart = now.subtract(Duration(
        days: now.weekday - 1,
        hours: now.hour,
        minutes: now.minute));
    var picked = weekStart.add(Duration(
        days: day,
        hours: start.floor(),
        minutes: (60 * (start % 1)).floor()
    ));

    await AppState.client.post(Uri.parse(scheduleUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(<String, dynamic>{
          'is_meeting': false,
          'day': picked.toUtc().weekday - 1,
          'start': picked.toUtc().toString(),
          'length': (60 * length).floor()
        }));
  }

  Future<void> deleteTimeSlot(String id) async {
    if (!isModifiable) {
      return;
    }
    await AppState.client.delete(Uri.parse("$apiUrl/time_slots/$id"),
        headers: {"Content-Type": "application/json"});
  }

  Future<void> updateTimeSlot(String id, int day, double start, double length) async {
    if (!isModifiable) {
      return;
    }

    var now = DateTime.now();
    var weekStart = now.subtract(Duration(
        days: now.weekday - 1,
        hours: now.hour,
        minutes: now.minute));
    var slotTime = weekStart.add(Duration(
        days: day,
        hours: start.floor(),
        minutes: (60 * (start % 1)).floor()
    ));

    var resp = await AppState.client.patch(Uri.parse("$apiUrl/time_slots/$id"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(<String, dynamic>{
          'id': id,
          'start': slotTime.toUtc().toString(),
          'length': (60 * length).floor()
        }));
    if (resp.statusCode != 200) {
      log(resp.body);
      throw Exception('Failed to update time slot');
    }
  }

  Future<SchedulePage?> tryParseUserScheduleLink(Uri uri) async {
    final regex = RegExp(r'^/users/([0-9a-z]+)/time_slots$');
    final match = regex.firstMatch(uri.path);
    if (match != null) {
      final userId = match.group(1)!;
      final response =
          await AppState.client.get(Uri.parse("$apiUrl/users/$userId"));
      if (response.statusCode != 200) {
        throw Exception('Failed to parse user schedule link');
      }
      return SchedulePage(
          ownerId: userId, ownerName: json.decode(response.body)["username"]);
    }
    return null;
  }

  Future<Group?> tryParseGroupJoinLink(Uri uri) async {
    final regex = RegExp(r'^/groups/([0-9a-z]+)/join$');
    final match = regex.firstMatch(uri.path);
    if (match != null) {
      final groupId = match.group(1)!;
      final response =
          await AppState.client.get(Uri.parse("$apiUrl/groups/$groupId"));
      if (response.statusCode != 200) {
        return null;
      }
      return Group.fromJson(json.decode(response.body));
    }
    return null;
  }
}
