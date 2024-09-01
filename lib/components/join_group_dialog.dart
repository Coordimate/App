import 'package:coordimate/app_state.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';
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
            final group = await AppState.groupController.joinGroup(groupId);
            if (context.mounted) {
              Navigator.of(context).pop();
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
