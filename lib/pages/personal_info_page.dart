import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/login_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/pages/start_page.dart';
import 'package:coordimate/data/storage.dart';
import 'dart:convert';
import 'package:coordimate/api_client.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/models/user.dart';
import 'package:flutter/widgets.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {

  late User user;
  bool isEditing = false;
  final usernameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    // getInfo(); // TODO: Uncomment this line
    // usernameController.text = user.username; // TODO: Uncomment this line
    usernameController.text = "John Doe";
  }

  void logOut(BuildContext context) {
    logUserOutStorage();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => StartPage(key: UniqueKey())));
  }

  Future<void> getInfo() async {
    var url = Uri.parse("$apiUrl/???"); // TODO: Add the correct endpoint
    final response = await client.get(
        url,
        headers: {"Content-Type": "application/json"}
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }
    user = json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
          title: 'Personal Page',
          needButton: false
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: const NetworkImage('https://www.w3schools.com/w3images/avatar2.png'),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final textSpan = TextSpan(
                        text: usernameController.text,
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: darkBlue),
                      );
                      final textPainter = TextPainter(
                        text: textSpan,
                        textDirection: TextDirection.ltr,
                      );
                      textPainter.layout();
                      double textWidth = textPainter.width;

                      double screenWidth = MediaQuery.of(context).size.width;
                      double padding = 26.0; // Change this value as needed
                      double iconWidth = 50; // Change this value as needed
                      double maxWidth = screenWidth - padding * 2 - iconWidth;

                      if (textWidth > maxWidth) {
                        textWidth = maxWidth;
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: textWidth < constraints.maxWidth ? textWidth : constraints.maxWidth,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {}); // Rebuild the widget when text changes
                              },
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(border: InputBorder.none,),
                              controller: usernameController,
                              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: darkBlue),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: darkBlue),
                            onPressed: () {
                              // Implement your change username functionality here
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text('string@email.com', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: darkBlue)),
                  const SizedBox(height: 16),

                  LoginEmptyButton(
                      text: "Change Password",
                      onTap: (){}
                  ),
                  const SizedBox(height: 8),
                  LoginButton(
                      text: "Logout",
                      onTap: () { logOut(context); }
                  ),


                ],
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.only(bottom: 16),
              child: TextButton(
                onPressed: () {
                  // Implement your delete account functionality here
                },
                child: const Text(
                  'Delete Account',
                  style: TextStyle(color: mediumBlue, fontSize: 20, fontWeight: FontWeight.w500),
                ),
              )),
        ],
      ),
    );
  }
}