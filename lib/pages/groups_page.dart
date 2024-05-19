import 'package:flutter/material.dart';

import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/keys.dart';

import 'dart:convert';
import 'package:coordimate/api_client.dart';

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
    final response = await client.get(Uri.parse("$apiUrl/groups/"));
    final List body = json.decode(response.body)["groups"];
    setState(() {
      _groups = body.map((e) => Group.fromJson(e)).toList();
    });
    return _groups;
  }

  Future<void> _createGroup(String name, String description) async {
    final response = await client.post(
      Uri.parse("$apiUrl/groups/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'description': description,
      }),
    );
    if (response.statusCode == 201) {
      _getGroups();
    } else {
      throw Exception('Failed to create meeting');
    }
  }

  _showAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String groupName = ''; // Variable to store the entered title
        String groupDescription =
            ''; // Variable to store the entered description

        return AlertDialog(
          title: const Text(
            'Create Group',
            style:
                TextStyle(color: Colors.white), // Change title color to white
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  onChanged: (val) {
                    groupName =
                        val; // Update the newNoteTitle variable with the entered title
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    labelText: 'Title', // Label text for the title field
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white)), // Use white outline
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white)), // Use white outline
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                darkBlue)), // Change focused border color to hex value 293241
                    labelStyle: const TextStyle(
                        color: Colors.white), // Change label color to white
                    counterText:
                        '${groupName.length}/20', // Add character counter
                    counterStyle: const TextStyle(
                        color:
                            Colors.white), // Change counter text color to white
                  ),
                  maxLength: 20, // Set maximum length for the title
                  style: const TextStyle(
                      color: Colors.white), // Change input text color to white
                ),
                const SizedBox(
                    height:
                        10), // Add some space between title and description fields
                TextFormField(
                  onChanged: (val) {
                    groupDescription =
                        val; // Update the newNoteDescription variable with the entered description
                  },
                  maxLines:
                      3, // Increase the number of lines for the description field
                  maxLength: 300, // Set maximum length for the description
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    labelText:
                        'Description', // Label text for the description field
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white)), // Use white outline
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white)), // Use white outline
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                darkBlue)), // Change focused border color to hex value 293241
                    labelStyle: const TextStyle(
                        color: Colors.white), // Change label color to white
                    counterText:
                        '${groupDescription.length}/300', // Add character counter
                    counterStyle: const TextStyle(
                        color:
                            Colors.white), // Change counter text color to white
                  ),
                  style: const TextStyle(
                      color: Colors.white), // Change input text color to white
                ),
              ],
            ),
          ),
          backgroundColor:
              mediumBlue, // Set background color to hex value 3D5A80
          actions: [
            SizedBox(
              width: double.infinity, // Set width to match screen width
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // Align to the right
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      if (groupName.isNotEmpty && groupName.length <= 20) {
                        await _createGroup(groupName, groupDescription);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'Create Group',
                      style: TextStyle(
                          color: Colors
                              .white), // Change button text color to white
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  _resetNotes() {
    setState(() {
      _groups.clear(); // Clear the list to reset notes
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: CustomAppBar(
                  title: "Groups",
                  needButton: true,
                  onPressed: _showAlertDialog),
              body: ListView.builder(
                itemCount: _groups.length,
                itemBuilder: (context, index) {
                  // Splitting the note into title and description
                  return Container(
                    decoration: BoxDecoration(
                      color:
                          darkBlue, // Set background color of the card to grey
                      borderRadius: BorderRadius.circular(
                          10), // Add border radius to make it look like a card
                    ),
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Container(
                          width: 70, // Set the width of the circle
                          height: 70, // Set the height of the circle
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, // Make it a circle
                            color: Colors.white, // Set color to white
                          ),
                        ),
                        const SizedBox(
                            width:
                                10), // Add some space between the circle and text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _groups[index].name,
                                style: const TextStyle(
                                  fontSize: 30, // Font size for title
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.bold, // Make the title bold
                                ),
                              ),
                              const SizedBox(
                                  height:
                                      5), // Add some vertical space between title and description
                              Text(
                                _groups[index].description,
                                style: const TextStyle(
                                  fontSize: 16, // Font size for description
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else {
            return Text("Oh Shit!");
          }
        });
  }
}
