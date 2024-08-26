import 'package:coordimate/components/avatar.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/create_group_dialog.dart';
import 'group_details_page.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:coordimate/text_overflow_detect.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  List<Group> groups = [];

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    final fetchedGroups = await AppState.groupController.getGroups();
    setState(() {
      groups = fetchedGroups;
    });
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CreateGroupDialog(
            onCreateGroup: AppState.groupController.createGroup,
            fetchGroups: _fetchGroups);
      },
    );
  }

  Future<void> _navigateToGroupDetails(Group group) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsPage(group: group),
      ),
    );

    if (result == true) {
      _fetchGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Groups",
        needButton: true,
        onPressed: _showCreateGroupDialog,
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _navigateToGroupDetails(groups[index]),
            child: Container(
              key: groupCardKey,
              decoration: BoxDecoration(
                color: darkBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Avatar(key: UniqueKey(), size: 70, groupId: groups[index].id),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EllipsisText(
                          key: UniqueKey(),
                          text: groups[index].name,
                          textKey: groupCardNameKey,
                          overflowKey: groupCardNameOverflowKey,
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                        ),
                        // Text(
                        //   key: groupCardNameKey,
                        //   groups[index].name,
                        //   style: const TextStyle(
                        //     fontSize: 30,
                        //     color: Colors.white,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                        const SizedBox(height: 5),
                        EllipsisText(
                          key: UniqueKey(),
                          text: groups[index].description,
                          textKey: groupCardDescriptionKey,
                          overflowKey: groupCardDescriptionOverflowKey,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                        ),
                        // Text(
                        //   key: groupCardDescriptionKey,
                        //   groups[index].description,
                        //   style: const TextStyle(
                        //     fontSize: 16,
                        //     color: Colors.white,
                        //   ),
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
