import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:coordimate/data/storage.dart';

class FacebookSignInApi {
static final FacebookAuth _facebookAuth = FacebookAuth.instance;

  static Future<Map<String, String>?> login() async {
    try {
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email'],
      );
      if (result.status == LoginStatus.success) {
        final userData = await _facebookAuth.getUserData();
        if (userData['email'] == null || userData['name'] == null) return null;
        final String email = userData['email'] as String;
        final String name = userData['name'] as String;
        bool res = await signUserInStorage(email, AuthType.facebook);
        if (res) {
          print('Facebook User signed in successfully');
        } else {
          res = await registerUserStorage(email, name, AuthType.facebook);
          if (res) {
            print('Facebook User registered successfully');
          } else {
            print('Facebook User failed to sign in or register');
          }
        }
        return {'email': email, 'name': name};
      } else {
        print('Facebook User failed to sign in');
        return null;
      }
    } catch (error) {
      print(error);
      return null;
    }
  }

  static Future<void> logout() async {
    await _facebookAuth.logOut();
  }
}