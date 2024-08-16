import 'package:another_flushbar/flushbar.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/avatar.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/login_button.dart';
import 'package:coordimate/components/pop_up_dialog.dart';
import 'package:coordimate/components/text_field_with_edit.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/pages/start_page.dart';
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/models/user.dart';
import 'package:coordimate/components/login_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  var showChangePasswordButton = true;

  Future<bool> checkAuthType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('sign_in_method') == signInType[AuthType.email];
  }

  void logOut(BuildContext context) async {
    await AppState.authController.signOut();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => StartPage(key: UniqueKey())));
  }

  Future<User> getInfo() async {
    user = await AppState.userController.getInfo();
    usernameController.text = user.username;
    userEmail = user.email;
    showChangePasswordButton = await checkAuthType();
    return user;
  }

  Future<void> changeUsername(username) async {
    if (username == user.username || username.isEmpty) {
      return;
    }
    await AppState.userController.changeUsername(username, user.id);
    user.username = username;
  }

  Future<void> deleteUser() async {
    await AppState.userController.deleteUser(user.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account deleted successfully'),
        duration: Duration(seconds: 2),
      ),
    );
    logOut(context);
  }

  void showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopUpDialog(
          question: "Do you want to delete your account?",
          onYes: () async {
            await deleteUser();
          },
        );
      },
    );
  }

  void showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const ChangePasswordDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Scaffold(
                backgroundColor: white,
                appBar:
                CustomAppBar(title: 'Personal Page', needButton: false),
                body: Center(child: Text('Failed to load data')));
          } else if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: white,
              appBar:
                  const CustomAppBar(title: 'Personal Page', needButton: false),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Avatar(size: 120, key: UniqueKey(), userId: user.id, clickable: true),
                    const SizedBox(height: 16),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: horPadding),
                      child: EditableTextField(
                        controller: usernameController,
                        focusNode: focusNode,
                        onSubmit: changeUsername,
                        fontSize: usernameFontSize, // not required
                        padding: horPadding, // not required
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(userEmail,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: darkBlue)),
                    const SizedBox(height: 16),
                    if (showChangePasswordButton)
                      LoginEmptyButton(
                        text: "Change Password",
                        onTap: showChangePasswordDialog,
                      ),
                    if (showChangePasswordButton) const SizedBox(height: 8),
                    LoginButton(
                        text: "Logout",
                        onTap: () {
                          logOut(context);
                        }),
                  ],
                ),
              ),
              bottomSheet: Container(
                color: white,
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextButton(
                    onPressed: showDeleteAccountDialog,
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(
                          color: mediumBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    )),
              ),
            );
          } else {
            return const Scaffold(
                backgroundColor: white,
                appBar:
                CustomAppBar(title: 'Personal Page', needButton: false),
                body: Center(child: CircularProgressIndicator()));
          }
        });
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

  Future<bool> changePassword() async {
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
    if (newPasswordController.text == oldPasswordController.text) {
      Flushbar(
        message: 'New password is the same as the old one',
        duration: const Duration(seconds: 2),
        backgroundColor: orange,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return false;
    }
    var res = await AppState.userController.sendChangePswdRequest(
        newPasswordController.text, oldPasswordController.text);
    if (res == false) {
      if (!mounted) return false;
      Flushbar(
        message: 'Old password is incorrect',
        duration: const Duration(seconds: 2),
        backgroundColor: orange,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0.0,
      backgroundColor: white,
      alignment: Alignment.center,
      title: const Center(child: Text('Change Password')),
      titleTextStyle: const TextStyle(
          color: darkBlue, fontSize: 24, fontWeight: FontWeight.bold),
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
        ConfirmationButtons(
          onYes: () async {
            var isValid = await changePassword();
            if (isValid) {
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
          onNo: () {
            Navigator.of(context).pop();
          },
          yes: "Continue",
          no: "Cancel",
        ),
      ],
    );
  }
}
