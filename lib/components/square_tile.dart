import 'package:flutter/material.dart';
import 'package:coordimate/api/google_api.dart';
import 'package:coordimate/api/facebook_api.dart';
import 'package:coordimate/screens/home_screen.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/data/storage.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final AuthType authType;

  const SquareTile({
    super.key,
    required this.imagePath,
    required this.authType,
  });

  Future<bool> _authGoogle() async {
    print('Google Auth');
    final user = await GoogleSignInApi.login();
    if (user != null) {
      print('Google User: ${user.displayName}, ${user.email}, ${user.id}');
      return true;
    } else {
      print('Google Sign In Failed');
      return false;
    }
  }

  Future<bool> _authFacebook() async {
    print('Facebook Auth');
    final user = await FacebookSignInApi.login();
    if (user != null) {
      print("${user['name']} ${user['email']}");
      return true;
    } else {
      print('Facebook Sign In Failed');
      return false;
    }
  }

  Future<void> _authUser() async {
    bool auth = false;
    switch (authType) {
      case AuthType.google:
        auth = await _authGoogle();
        break;

      case AuthType.facebook:
        auth = await _authFacebook();
        break;

      default:
        break;
    }

    if (auth) {
      print('User Authenticated');
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen(key: UniqueKey())),
            (route) => false,
      );
    } else {
      print('User Not Authenticated');
    }
    // GoogleSignInApi.logout();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _authUser,
      style: ButtonStyle(
        shape: MaterialStateProperty.all(const CircleBorder()),
        backgroundColor: MaterialStateProperty.all(Colors.white),
      ),
      child: Image.asset(
        imagePath,
        height: 60,
        width: 60,
      ),
    );
  }
}