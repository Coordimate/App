import 'dart:convert';
import 'package:coordimate/models/time_slot.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/app_state.dart';


class ScheduleController {
  String scheduleUrl = '';
  String pageTitle = 'Schedule';
  bool isModifiable = false;
  bool canCreateMeeting = false;

  Future<List<TimeSlot>> getTimeSlots() async {
    var url = Uri.parse(scheduleUrl);
    final response =
    await AppState.authController.client.get(url, headers: {"Content-Type": "application/json"});
    final List body = json.decode(response.body)['time_slots'];
    return body.map((e) => TimeSlot.fromJson(e)).toList();
  }

  Future<void> createTimeSlot(int day, double start, double length) async {
    if (!isModifiable) {
      return;
    }
    await AppState.authController.client.post(Uri.parse(scheduleUrl),
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
    await AppState.authController.client.delete(Uri.parse("$apiUrl/time_slots/$id"),
        headers: {"Content-Type": "application/json"});
  }

  Future<void> updateTimeSlot(String id, double start, double length) async {
    if (!isModifiable) {
      return;
    }
    await AppState.authController.client.patch(Uri.parse("$apiUrl/time_slots/$id"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(<String, dynamic>{
          'id': id,
          'start': start.toStringAsFixed(2),
          'length': length.toStringAsFixed(2)
        }));
  }
}