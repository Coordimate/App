import 'package:another_flushbar/flushbar.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/login_button.dart';
import 'package:coordimate/components/pop_up_dialog.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/pages/start_page.dart';
import 'package:coordimate/data/storage.dart';
import 'dart:convert';
import 'package:coordimate/api_client.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/models/user.dart';
import 'package:coordimate/components/login_text_field.dart';

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
    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      logOut(context);
    }
  }

  void showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopUpDialog(
          question: "Do you want to delete your account?",
          onYes: () async { await deleteUser(); },
        );
      },
    );
  }

  void showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangePasswordDialog();
      },
    );
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
                      onTap: showChangePasswordDialog,
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
                  onPressed: showDeleteAccountDialog,
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

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  static const pathLock = 'lib/images/lock.png';
  final _formKey = GlobalKey<FormState>();

  Future<void> sendChangePswdRequest() async {
    final id = await storage.read(key: 'id_account');
    var url = Uri.parse("$apiUrl/users/$id");
    final response = await client.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(<String, dynamic>{
          'password': newPasswordController.text,
        })
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to save data');
    }
  }

   bool changePassword() {
    if (_formKey.currentState!.validate() == false) {
      return false;
    }
    if (newPasswordController.text != repeatPasswordController.text) {
        Flushbar(
          message: 'Passwords do not match',
          duration: const Duration(seconds: 2),
          backgroundColor: orange,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      return false;
    }
    sendChangePswdRequest();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      alignment: Alignment.center,
      title: const Center(child: Text('Change Password')),
      titleTextStyle: const TextStyle(color: darkBlue, fontSize: 24, fontWeight: FontWeight.bold),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LoginTextField(
              controller: oldPasswordController,
              obscureText: true,
              hintText: 'Old password',
              label: 'old password',
              icon: pathLock,
              keyboardType: TextInputType.visiblePassword,
            ),
            LoginTextField(
              controller: newPasswordController,
              obscureText: true,
              hintText: 'New password',
              label: 'new password',
              icon: pathLock,
              keyboardType: TextInputType.visiblePassword,
            ),
            LoginTextField(
              controller: repeatPasswordController,
              obscureText: true,
              hintText: 'Repeat password',
              label: 'new password',
              icon: pathLock,
              keyboardType: TextInputType.visiblePassword,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (changePassword()) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password changed successfully'),
                        duration: Duration(seconds: 1),
                        backgroundColor: darkBlue,
                      ),
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(mediumBlue),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: const Text("Continue",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  side: MaterialStateProperty.all(const BorderSide(color: mediumBlue, width: 3)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: const Text("Cancel",
                    style: TextStyle(color: mediumBlue, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}