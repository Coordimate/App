import 'package:flutter/material.dart';
import 'package:coordimate/api/google_api.dart';

enum AuthType {
  google,
  facebook,
}

class SquareTile extends StatelessWidget {
  final String imagePath;
  final AuthType authType;

  const SquareTile({
    super.key,
    required this.imagePath,
    required this.authType,
  });

  Future<void> _authGoogle() async {
    print('Google Auth');
    final user = await GoogleSignInApi.login();
    if (user != null) {
      print('Google User: ${user.displayName}, ${user.email}');
    } else {
      print('Google Sign In Failed');
    }
  }

  void _authFacebook() {
    print('Facebook Auth');
  }

  void _authUser() {
    switch (authType) {
      case AuthType.google:
        _authGoogle();
        break;
      case AuthType.facebook:
        _authFacebook();
        break;
    }
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