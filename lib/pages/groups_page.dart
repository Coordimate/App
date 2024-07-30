import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/app_state.dart';
import 'group_details_page.dart';

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
    _fetchGroups();
  }

  Future<void> _navigateToGroupDetails(Group group) async {
    // Function to navigate to GroupDetailsPage
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsPage(group: group),
      ),
    );

    if (result == true) {
      // Reload groups when coming back
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
              decoration: BoxDecoration(
                color: darkBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groups[index].name,
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow
                              .ellipsis, // Truncate text with ellipsis
                        ),
                        const SizedBox(height: 5),
                        Text(
                          groups[index].description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow
                              .ellipsis, // Truncate text with ellipsis
                        ),
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

class CreateGroupDialog extends StatefulWidget {
  final Future<void> Function(String name, String description) onCreateGroup;
  final Future<void> Function() fetchGroups;

  const CreateGroupDialog(
      {super.key, required this.onCreateGroup, required this.fetchGroups});

  @override
  CreateGroupDialogState createState() => CreateGroupDialogState();
}

class CreateGroupDialogState extends State<CreateGroupDialog> {
  String groupName = '';
  String groupDescription = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Create Group',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              onChanged: (val) {
                setState(() {
                  groupName = val;
                });
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                labelText: 'Title',
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: darkBlue),
                ),
                labelStyle: const TextStyle(color: Colors.white),
                counterText: '${groupName.length}/20',
                counterStyle: const TextStyle(color: Colors.white),
              ),
              maxLength: 20,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (val) {
                setState(() {
                  groupDescription = val;
                });
              },
              maxLines: null,
              // Allow the TextField to expand vertically based on content
              maxLength: 100,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                labelText: 'Description',
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: darkBlue),
                ),
                labelStyle: const TextStyle(color: Colors.white),
                counterText: '${groupDescription.length}/100',
                counterStyle: const TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      backgroundColor: mediumBlue,
      actions: [
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () async {
                  if (groupName.isNotEmpty && groupName.length <= 20) {
                    await widget.onCreateGroup(groupName, groupDescription);
                    await widget.fetchGroups();
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Create Group',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
