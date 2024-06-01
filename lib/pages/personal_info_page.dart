import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/login_button.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/pages/start_page.dart';
import 'package:coordimate/data/storage.dart';
import 'dart:convert';
import 'package:coordimate/api_client.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/models/user.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {

  late User user;
  bool isEditing = false;
  final usernameController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  static const usernameFontSize = 30.0;
  static const horPadding = 24.0;

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  void logOut(BuildContext context) {
    logUserOutStorage();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => StartPage(key: UniqueKey())));
  }

  Future<void> getInfo() async {
    final id = await storage.read(key: 'id_account');
    var url = Uri.parse("$apiUrl/users/$id");
    final response = await client.get(
        url,
        headers: {"Content-Type": "application/json"}
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }
    user = User.fromJson(json.decode(response.body));
    usernameController.text = user.username;
  }

  Future<void> saveUsername() async {
    var url = Uri.parse("$apiUrl/???"); // TODO: Add the correct endpoint
    final response = await client.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(user.toJson())
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to save data');
    }
  }

  Future<void> deleteUser() async {
    final id = user.id;
    var url = Uri.parse("$apiUrl/users/"); // TODO: Add the correct endpoint
    final response = await client.delete(
        url,
        headers: {"Content-Type": "application/json"}
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Personal Page',
          needButton: false
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: const NetworkImage('https://www.w3schools.com/w3images/avatar2.png'),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: horPadding),
              child: TextField(
                controller: usernameController,
                textAlign: TextAlign.center,
                readOnly: isEditing == false,
                focusNode: focusNode,
                maxLines: null,
                keyboardType: TextInputType.text, // makes Enter a submission button
                style: const TextStyle(fontSize: usernameFontSize, fontWeight: FontWeight.bold, color: darkBlue),
                onSubmitted: (value) {
                  setState(() { isEditing = false; });
                  // Implement your save username functionality here // TODO
                },
                decoration: InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: isEditing ?
                    const UnderlineInputBorder(borderSide: BorderSide(color: darkBlue))
                    : InputBorder.none,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() { isEditing = !isEditing; });
                      if (isEditing) {
                        focusNode.requestFocus();
                      } else
                      if (!isEditing) {
                        // Implement your save username functionality here //TODO
                      }
                    },
                    icon: Icon(
                      isEditing ? Icons.check : Icons.edit, // Change the icon based on the editing state
                      color: darkBlue,
                      size: usernameFontSize - 4,
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(left: usernameFontSize + horPadding),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('string@email.com', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: darkBlue)),
            const SizedBox(height: 16),

            LoginButton(
                text: "Logout",
                onTap: () { logOut(context); }
            ),
            const SizedBox(height: 8),
            LoginEmptyButton(
                text: "Change Password",
                onTap: (){}
            ),
          ],
        ),
      ),

    );
  }
}