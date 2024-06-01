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
  var userEmail = '';

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
    print("got user info");
    usernameController.text = user.username;
    userEmail = user.email;
  }

  Future<void> changeUsername(username) async {
    if (username == user.username || username.isEmpty) {
      return;
    }
    var url = Uri.parse("$apiUrl/users/${user.id}");
    final response = await client.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(<String, dynamic>{
          'username': username,
        })
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to save data');
    }
    user.username = username;
  }

  Future<void> deleteUser() async {
    var url = Uri.parse("$apiUrl/users/${user.id}");
    final response = await client.delete(
        url,
        headers: {"Content-Type": "application/json"}
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    } else {
      if (!mounted) return;
      logOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load data'));
          } else {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: const CustomAppBar(
                  title: 'Personal Page',
                  needButton: false
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 70,
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
                          changeUsername(value);
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
                              } else if (!isEditing) {
                                changeUsername(usernameController.text);
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
                    Text(userEmail, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: darkBlue)),
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
              bottomSheet: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextButton(
                  onPressed: () {
                    deleteUser();
                  },
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(color: mediumBlue, fontSize: 20, fontWeight: FontWeight.w500 ),
                  )
                ),
              ),
            );
          }
        }
    );
  }
}