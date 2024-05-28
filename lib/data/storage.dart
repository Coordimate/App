import 'package:coordimate/api/google_api.dart';
import 'package:coordimate/keys.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:coordimate/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();
enum AuthType {
  google,
  facebook,
  email,
}
const signInType = {
  AuthType.google : 'google',
  AuthType.facebook : 'facebook',
  AuthType.email : 'email',
};

void logUserOutStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? signInMethod = prefs.getString('sign_in_method');
  print("sign method: $signInMethod");

  storage.delete(key: 'refresh_token');
  storage.delete(key: 'access_token');

  prefs.remove('access_token');
  prefs.remove('refresh_token');

  if (signInMethod == signInType[AuthType.google]) {
    await GoogleSignInApi.logout();
  } else if (signInMethod == signInType[AuthType.facebook]) {
    // Call Facebook logout function
  }
}

Future<bool> signUserInStorage(email, signInMethod, {pswd}) async {
  var url = Uri.parse("$apiUrl/login");

  User user = User(
    email: email,
  );
  if (signInMethod == AuthType.email) {
    user = User(
      email: email,
      password: pswd,
    );
  }

  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json.encode(user),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);
    print("User signed in successfully");

    final String accessToken = data['access_token'];
    final String refreshToken = data['refresh_token'];
    await storage.write(key: 'access_token', value: accessToken);
    await storage.write(key: 'refresh_token', value: refreshToken);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('access_token', accessToken);
    prefs.setString('refresh_token', refreshToken);
    if (signInMethod == AuthType.google) {
      prefs.setString('sign_in_method', signInType[AuthType.google]!);
    } else if (signInMethod == AuthType.facebook) {
      prefs.setString('sign_in_method', signInType[AuthType.facebook]!);
    } else {
      prefs.setString('sign_in_method', signInType[AuthType.email]!);
    }

    return true;
  } else {
    print("Failed to sign in with response code ${response.statusCode}");
    return false;
  }
}

Future<bool> registerUserStorage(email, username, signInMethod, {pswd}) async {
  var url = Uri.parse("$apiUrl/register");

  User user = User(
    username: username,
    email: email,
  );

  if (signInMethod == AuthType.email) {
    user = User(
      username: username,
      email: email,
      password: pswd,
    );
  }

  final jsonUser = json.encode(user);
  // print(jsonUser);

  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonUser,
  );

  // print(response.statusCode);

  if (response.statusCode == 201) {
    print("User registered successfully");
    return await signUserInStorage(email, signInMethod, pswd : pswd);
  } else if (response.statusCode == 400) {
    print("User with email $email already exists");
    return false;
  }
  print("User registration failed ${response.statusCode}");
  return false;
}

