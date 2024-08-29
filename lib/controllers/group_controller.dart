import 'dart:convert';
import 'dart:developer';

import 'package:coordimate/app_state.dart';
import 'package:coordimate/models/chat_message.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/models/user.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/keys.dart';

class GroupController {
  Group? group;

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

  Future<Group> getGroup(id) async {
    final response = await AppState.client.get(Uri.parse("$apiUrl/groups/$id"));
    if (response.statusCode == 200) {
      // Checks for successful response
      final body = json.decode(response.body);
      group = Group.fromJson(body);
      return group!;
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

  Future<void> deleteGroup(String id) async {
    var url = Uri.parse("$apiUrl/groups/$id");
    final response = await AppState.client.delete(url,
        headers: {
          "Content-Type": "application/json",
        });
    if (response.statusCode != 204) {
      throw Exception('Failed to delete group');
    }
  }

  Future<void> leaveGroup(String id) async {
    var url = Uri.parse("$apiUrl/groups/$id/leave");
    final response = await AppState.client.post(url,
        headers: {
          "Content-Type": "application/json",
        });
    if (response.statusCode != 200) {
      throw Exception('Failed to leave group');
    }
  }

  Future<void> removeUser(id, userId) async {
    // TODO
    // var url = Uri.parse("$apiUrl/groups/$id/remove_user/$userId");
    // final response = await AppState.client.delete(url,
    //     headers: {
    //       "Content-Type": "application/json",
    //     });
    // if (response.statusCode != 204) {
    //   throw Exception('Failed to remove user');
    // }
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

  Future<List<ChatMessageModel>> fetchGroupChatMessages(id) async {
    final response = await AppState.client.get(Uri.parse("$apiUrl/groups/$id"));

    if (response.statusCode == 200) {
      return (json.decode(json.decode(response.body)['chat_messages']) as List)
          .map((data) => ChatMessageModel.fromJson(data))
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

  Future<void> createPoll(id, pollData) async {
    var url = Uri.parse("$apiUrl/groups/$id");
    final response = await AppState.client
        .patch(url, headers: {"Content-Type": "application/json"}, body: json.encode({
      "poll": json.decode(pollData)
    }));
    if (response.statusCode != 200) {
      log(response.body);
      throw Exception('Failed to create the group poll');
    }
  }

  Future<GroupPoll?> fetchPoll(id) async {
    var url = Uri.parse("$apiUrl/groups/$id");
    final response = await AppState.client
        .get(url, headers: {"Content-Type": "application/json"});
    if (response.statusCode != 200) {
      log(response.body);
      throw Exception('Failed to get the group poll');
    }
    return GroupPoll.fromJson(json.decode(response.body)['poll']);
  }

  Future<void> deletePoll(id) async {
    var url = Uri.parse("$apiUrl/groups/$id/poll");
    final response = await AppState.client
        .delete(url, headers: {"Content-Type": "application/json"});
    if (response.statusCode != 200) {
      log(response.body);
      throw Exception('Failed to delete the group poll');
    }
  }

  Future<void> voteOnPoll(id, optionIndex) async {
    var url = Uri.parse("$apiUrl/groups/$id/poll/$optionIndex");
    final response = await AppState.client
        .post(url, headers: {"Content-Type": "application/json"});
    if (response.statusCode != 200) {
      log(response.body);
      throw Exception('Failed to vote on the group poll');
    }
  }

  Future<void> updateGroupMeetingLink(String id, String link) async {
    var url = Uri.parse("$apiUrl/groups/$id");
    final response = await AppState.client.patch(url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(<String, dynamic>{
          'meeting_link': link,
        }));
    if (response.statusCode != 200) {
      throw Exception('Failed to update group meeting link');
    }
  }
}
