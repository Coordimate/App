import 'package:coordimate/keys.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:coordimate/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

Future<bool> signUserInStorage(pswd, email) async {
  var url = Uri.parse("$apiUrl/login");

  final User user = User(
    email: email,
    password: pswd,
  );

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

    return true;
  } else {
    print("Failed to sign in with response code ${response.statusCode}");
    return false;
  }
}

Future<bool> registerUserStorage(pswd, email, username) async {
  var url = Uri.parse("$apiUrl/register");

  final User user = User(
    username: username,
    email: email,
    password: pswd,
  );

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
    return await signUserInStorage(pswd, email);
  } else if (response.statusCode == 400) {
    print("User with email $email already exists");
    return false;
  }
  print("User registration failed ${response.statusCode}");
  return false;
}

