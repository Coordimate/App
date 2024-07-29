import 'dart:convert';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/models/groups.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/pages/group_details_page.dart';

class JoinGroupDialog extends StatelessWidget {
  const JoinGroupDialog({
    required super.key,
    required this.groupId,
    required this.groupName,
  });

  final String groupId;
  final String groupName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(groupName),
      content: const Text('You were invited to join the group!',
          style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold)),
      actions: <Widget>[
        TextButton(
          child: const Text('Reject',
              style: TextStyle(
                  color: darkBlue, fontWeight: FontWeight.bold, fontSize: 20)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Accept',
              style: TextStyle(
                  color: darkBlue, fontWeight: FontWeight.bold, fontSize: 20)),
          onPressed: () async {
            await AppState.client.post(Uri.parse("$apiUrl/groups/$groupId/join"),
                headers: {"Content-Type": "application/json"});
            if (context.mounted) {
              Navigator.of(context).pop();
            }
            final response = await AppState.client.get(Uri.parse("$apiUrl/groups/$groupId"));
            if (response.statusCode == 200) {
              final group = Group.fromJson(json.decode(response.body));
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GroupDetailsPage(group: group),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
