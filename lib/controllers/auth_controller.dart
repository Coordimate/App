import 'dart:developer';
import 'dart:convert';
import 'package:coordimate/app_state.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis/calendar/v3.dart';

import 'package:coordimate/keys.dart';

enum AuthType {
  google,
  facebook,
  email,
}

const signInType = {
  AuthType.google: 'google',
  AuthType.facebook: 'facebook',
  AuthType.email: 'email',
};

class AuthorizationController {

  AuthorizationController({
    required this.plainClient,
  });

  final http.Client plainClient;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [CalendarApi.calendarEventsScope],
  );
  AuthClient? googleAuthClient;
  CalendarApi? calApi;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  Future<String?> getAccountId() async {
    return await AppState.storage.read(key: 'id_account');
  }

  Future<void> signOut() async {
    final prefs = await AppState.prefs;
    String? signInMethod = prefs.getString('sign_in_method');
    log("sign method: $signInMethod");

    await AppState.storage.delete(key: 'refresh_token');
    await AppState.storage.delete(key: 'access_token');

    prefs.remove('access_token');
    prefs.remove('refresh_token');

    if (signInMethod == signInType[AuthType.google]) {
      await _googleSignIn.signOut();
    } else if (signInMethod == signInType[AuthType.facebook]) {
      await _facebookAuth.logOut();
    }
    if (googleAuthClient != null) googleAuthClient!.close();
  }

  Future<bool> signIn(email, signInMethod, {password}) async {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      googleAuthClient = await _googleSignIn.authenticatedClient();
      if (googleAuthClient != null) {
        calApi = CalendarApi(googleAuthClient!);
      } else {
        log('googleAuthClient is null');
      }
    });

    Map<String, String> body;
    switch (signInMethod) {
      case AuthType.email:
        body = {
          "email": email,
          "password": password,
          "auth_type": signInType[AuthType.email]!
        };
      case AuthType.google:
        var googleUser = await _googleSignIn.signInSilently();
        if (googleUser == null) {
          if (await _googleSignIn.isSignedIn()) await _googleSignIn.signOut();
          googleUser = await _googleSignIn.signIn();
          if (googleUser == null) {
            log('Google User failed to sign in');
            return false;
          }
        }
        body = {
          "email": googleUser.email,
          "auth_type": signInType[AuthType.google]!
        };
      case AuthType.facebook:
        final LoginResult result = await _facebookAuth.login(permissions: ['email']);
        if (result.status != LoginStatus.success) {
          log('Facebook User failed to sign in');
          return false;
        }
        final userData = await _facebookAuth.getUserData();
        if (userData['email'] == null || userData['name'] == null) {
          log('Facebook User missing email or name');
          return false;
        }
        final String email = userData['email'] as String;
        body = {
          "email": email,
          "auth_type": signInType[AuthType.facebook]!
        };
      default:
        return false;
    }
    // TODO: register google and facebook users if they can't login yet

    final response = await plainClient.post(
      Uri.parse("$apiUrl/login"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(body),
    );
    if (response.statusCode != 200) {
      log("Failed to sign in with response code ${response.statusCode}");
      return false;
    }

    final data = json.decode(response.body);
    final String accessToken = data['access_token'];
    final String refreshToken = data['refresh_token'];

    await AppState.storage.write(key: 'access_token', value: accessToken);
    await AppState.storage.write(key: 'refresh_token', value: refreshToken);

    final prefs = await AppState.prefs;
    prefs.setString('access_token', accessToken);
    prefs.setString('refresh_token', refreshToken);
    prefs.setString('sign_in_method', signInType[signInMethod]!);

    final meResponse = await AppState.client.get(Uri.parse('$apiUrl/me'));
    if (meResponse.statusCode != 200) {
      log("error requesting user account from /me");
      return false;
    }
    final respBody = json.decode(meResponse.body);
    await AppState.storage.write(key: 'id_account', value: respBody['id']);
    return true;
  }

  Future<bool> register(email, username, signInMethod, {password}) async {
    Map<String, String> body;

    switch (signInMethod) {
      case AuthType.email:
        body = {
          "username": username,
          "email": email,
          "password": password,
          "auth_type": signInType[AuthType.email]!
        };
      case AuthType.google:
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return false;
        email = googleUser.email;
        body = {
          "username": username,
          "email": email,
          "password": password,
          "auth_type": signInType[AuthType.google]!
        };
      case AuthType.facebook:
        final LoginResult result = await _facebookAuth.login(permissions: ['email']);
        if (result.status != LoginStatus.success) {
          log('Facebook User failed to sign in');
          return false;
        }
        final userData = await _facebookAuth.getUserData();
        if (userData['email'] == null || userData['name'] == null) {
          log('Facebook User missing email or name');
          return false;
        }
        final String email = userData['email'] as String;
        final String name = userData['name'] as String;
        body = {
          "username": name,
          "email": email,
          "password": password,
          "auth_type": signInType[AuthType.facebook]!
        };
      default:
        return false;
    }

    final response = await plainClient.post(
      Uri.parse("$apiUrl/register"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      log("User registered successfully");
      return await signIn(email, signInMethod, password: password);
    } else if (response.statusCode == 400) {
      log("User with email $email already exists");
      return false;
    }
    log("User registration failed ${response.statusCode}");
    return false;
  }

  Future<bool> checkStoredToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");
    String? refreshToken = prefs.getString("refresh_token");
    if (accessToken != null && refreshToken != null) {
      await AppState.storage.write(key: 'access_token', value: accessToken);
      await AppState.storage.write(key: 'refresh_token', value: refreshToken);
    }
    final response = await AppState.client.get(Uri.parse('$apiUrl/me'));
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
