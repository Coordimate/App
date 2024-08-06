import 'dart:convert';

import 'package:share_plus/share_plus.dart';

import 'package:coordimate/app_state.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/models/user.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/keys.dart';

class GroupController {
  Future<List<Group>> getGroups() async {
    final response = await AppState.client.get(Uri.parse("$apiUrl/groups"));
    if (response.statusCode == 200) {
      // Checks for successful response
      final List body = json.decode(response.body)["groups"];
      return body.map((e) => Group.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load groups'); // Handles failed response
    }
  }

  Future<void> createGroup(String name, String description) async {
    final response = await AppState.client.post(
      Uri.parse("$apiUrl/groups"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'description': description,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create group');
    }
  }

  Future<List<MeetingTileModel>> fetchGroupMeetings(id) async {
    final response =
        await AppState.client.get(Uri.parse("$apiUrl/groups/$id/meetings"));

    if (response.statusCode == 200) {
      return (json.decode(response.body)['meetings'] as List)
          .map((data) => MeetingTileModel.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load group meetings');
    }
  }

  Future<void> createMeeting(String title, String start, String description, String groupId) async {
    final response = await AppState.client.post(
      Uri.parse("$apiUrl/meetings"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'start': start,
        'description': description,
        'group_id': groupId,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create meeting');
    }
  }

  Future<void> updateGroupDescription(String id, String description) async {
    var url = Uri.parse("$apiUrl/groups/$id");
    final response = await AppState.client.patch(url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(<String, dynamic>{
          'description': description,
        }));
    if (response.statusCode != 200) {
      throw Exception('Failed to update group description');
    }
  }

  Future<void> updateGroupName(String id, String name) async {
    var url = Uri.parse("$apiUrl/groups/$id");
    final response = await AppState.client.patch(url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
        }));
    if (response.statusCode != 200) {
      throw Exception('Failed to update group name');
    }
  }

  Future<List<UserCard>> fetchGroupUsers(id) async {
    final response = await AppState.client.get(Uri.parse("$apiUrl/groups/$id"));

    if (response.statusCode == 200) {
      return (json.decode(response.body)['users'] as List)
          .map((data) => UserCard.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load group users');
    }
  }

  Future<String> shareInviteLink(id) async {
    var url = Uri.parse("$apiUrl/groups/$id/invite");
    final response = await AppState.client
        .get(url, headers: {"Content-Type": "application/json"});
    if (response.statusCode != 200) {
      throw Exception('Failed to share schedule');
    }
    return json.decode(response.body)['join_link'].toString();
  }
}
