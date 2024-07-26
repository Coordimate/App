import 'dart:developer';
import 'dart:convert';

import 'package:coordimate/app_state.dart';
import 'package:coordimate/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:coordimate/keys.dart';

class GroupController {
  Future<void> fetchGroupMeetings() async {
    final response = await AppState.authController.client
        .get(Uri.parse("$apiUrl/groups/${widget.group.id}/meetings"));

    if (response.statusCode == 200) {
      setState(() {
        meetings = (json.decode(response.body)['meetings'] as List)
            .map((data) => MeetingTileModel.fromJson(data))
            .toList();
      });
    } else {
      throw Exception('Failed to load group meetings');
    }
  }

  Future<void> updateGroupDescription(description) async {
    var url = Uri.parse("$apiUrl/groups/${widget.group.id}");
    final response = await AppState.authController.client.patch(url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(<String, dynamic>{
          'description': description,
        }));
    if (response.statusCode != 200) {
      throw Exception('Failed to update group description');
    }
    widget.group.description = description;
  }

  Future<void> updateGroupName(name) async {
    var url = Uri.parse("$apiUrl/groups/${widget.group.id}");
    final response = await AppState.authController.client.patch(url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
        }));
    if (response.statusCode != 200) {
      throw Exception('Failed to update group name');
    }
    widget.group.name = name;
  }

  Future<List<UserCard>> fetchGroupUsers() async {
    final response =
    await AppState.authController.client.get(Uri.parse("$apiUrl/groups/${widget.group.id}"));

    if (response.statusCode == 200) {
      return (json.decode(response.body)['users'] as List)
          .map((data) => UserCard.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load group users');
    }
  }

  Future<void> shareInviteLink() async {
    var url = Uri.parse("$apiUrl/groups/${widget.group.id}/invite");
    final response =
    await AppState.authController.client.get(url, headers: {"Content-Type": "application/json"});
    if (response.statusCode != 200) {
      throw Exception('Failed to share schedule');
    }
    final body = json.decode(response.body)['join_link'].toString();
    Share.share(body);
  }
}
