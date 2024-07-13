import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:coordimate/screens/home_screen.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/controllers/auth_controller.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final AuthType authType;

  const SquareTile({
    super.key,
    required this.imagePath,
    required this.authType,
  });

  Future<bool> _authGoogle() async {
    return AppState.authController.signIn("", AuthType.google);
  }

  Future<bool> _authFacebook() async {
    return AppState.authController.signIn("", AuthType.google);
  }

  Future<void> _authUser() async {
    // return AppState.authController.signIn()
    bool isAuth = false;
    switch (authType) {
      case AuthType.google:
        isAuth = await _authGoogle();
        break;

      case AuthType.facebook:
        isAuth = await _authFacebook();
        break;

      default:
        break;
    }

    if (isAuth) {
      log('User Authenticated');
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen(key: UniqueKey())),
            (route) => false,
      );
    } else {
      log('User Not Authenticated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _authUser,
      style: ButtonStyle(
        shape: WidgetStateProperty.all(const CircleBorder()),
        backgroundColor: WidgetStateProperty.all(Colors.white),
      ),
      child: Image.asset(
        imagePath,
        height: 60,
        width: 60,
      ),
    );
  }
}