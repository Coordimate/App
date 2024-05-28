import 'package:coordimate/data/storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/pages/start_page.dart';
import 'package:coordimate/keys.dart';

class GoogleSignInApi {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> login() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      print('Google User: ${googleUser.displayName}, ${googleUser.email}, ${googleUser.id}');
      bool res = await signUserInStorage(googleUser.email, AuthType.google);
      if (res) {
        print('Google User signed in successfully');
      } else {
        res = await registerUserStorage(googleUser.email, googleUser.displayName, AuthType.google);
        if (res) {
          print('Google User registered successfully');
        } else {
          print('Google User failed to sign in or register');
        }
      }
      return googleUser;
    } catch (error) {
      print(error);
      return null;
    }
  }

  static Future<void> logout() async {
    await _googleSignIn.disconnect(); // or signOut but idk the difference
  }
}