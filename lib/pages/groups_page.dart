import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/app_state.dart';
import 'group_details_page.dart';
import 'dart:convert';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  Future<List<Group>>? _groupsFuture;
  List<Group> _groups = [];

  @override
  void initState() {
    super.initState();
    _groupsFuture = _getGroups();
  }

  Future<List<Group>> _getGroups() async {
    try {
      // Added error handling to catch exceptions
      final response = await AppState.client.get(Uri.parse("$apiUrl/groups"));
      if (response.statusCode == 200) {
        // Checks for successful response
        final List body = json.decode(response.body)["groups"];
        setState(() {
          _groups = body.map((e) => Group.fromJson(e)).toList();
        });
        return _groups;
      } else {
        throw Exception('Failed to load groups'); // Handles failed response
      }
    } catch (e) {
      print(e); //ToDo: also this one
      return [];
    }
  }

  Future<void> _createGroup(String name, String description) async {
    try {
      // Added error handling to catch exceptions
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
      if (response.statusCode == 201) {
        await _getGroups();
      } else {
        throw Exception('Failed to create group');
      }
    } catch (e) {
      print(e); //ToDo: is this necessary here?
    }
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CreateGroupDialog(onCreateGroup: _createGroup);
      },
    );
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
      _groupsFuture = _getGroups();
      setState(() {}); // Trigger a rebuild to show the updated groups
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Group>>(
      future: _groupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Scaffold(
            appBar: CustomAppBar(
                title: "Groups",
                needButton: false), // Added needButton parameter
            body: Center(child: Text('Failed to load groups')),
          );
        } else if (snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomAppBar(
              title: "Groups",
              needButton: true,
              onPressed: _showCreateGroupDialog,
            ),
            body: ListView.builder(
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _navigateToGroupDetails(_groups[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      color: darkBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                                _groups[index].name,
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
                                _groups[index].description,
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
        } else {
          return const Scaffold(
            appBar: CustomAppBar(
                title: "Groups",
                needButton: false), // Added needButton parameter
            body: Center(child: Text('No groups available')),
          );
        }
      },
    );
  }
}

class CreateGroupDialog extends StatefulWidget {
  final Future<void> Function(String name, String description) onCreateGroup;

  const CreateGroupDialog({super.key, required this.onCreateGroup});

  @override
  _CreateGroupDialogState createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
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
              maxLines:
                  null, // Allow the TextField to expand vertically based on content
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
                    Navigator.of(context).pop();
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
