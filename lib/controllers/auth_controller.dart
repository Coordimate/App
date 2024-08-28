import 'dart:developer';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis/calendar/v3.dart';

import 'package:coordimate/keys.dart';
import 'package:coordimate/app_state.dart';

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
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [CalendarApi.calendarEventsScope],
  );
  AuthClient? googleAuthClient;
  CalendarApi? calApi;
  String? userId;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  Future<String?> getAccountId() async {
    return await AppState.storage.read(key: 'id_account');
  }

  Future<bool> trySilentGoogleSignIn() async {
    googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      googleAuthClient = await googleSignIn.authenticatedClient();
      if (googleAuthClient != null) {
        calApi = CalendarApi(googleAuthClient!);
      } else {
        log('googleAuthClient is null');
      }
    });

    var googleUser = await googleSignIn.signInSilently();
    return (googleUser != null);
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
      await googleSignIn.signOut();
    } else if (signInMethod == signInType[AuthType.facebook]) {
      await _facebookAuth.logOut();
    }
    if (googleAuthClient != null) googleAuthClient!.close();
  }

  Future<bool> signIn(email, signInMethod, {password}) async {
    googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      googleAuthClient = await googleSignIn.authenticatedClient();
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
        var googleUser = await googleSignIn.signInSilently();
        if (googleUser == null) {
          if (await googleSignIn.isSignedIn()) await googleSignIn.signOut();
          googleUser = await googleSignIn.signIn();
          if (googleUser == null) {
            log('Google User failed to sign in');
            return false;
          }
        }
        body = {
          "email": googleUser.email,
          "auth_type": signInType[AuthType.google]!
        };
        final photoUrl = googleUser.photoUrl;
        if (photoUrl != null) await _uploadGoogleProfileImage(photoUrl);
      case AuthType.facebook:
        final LoginResult result =
            await _facebookAuth.login(permissions: ['email']);
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
        body = {"email": email, "auth_type": signInType[AuthType.facebook]!};
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
    userId = respBody['id'];
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
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) return false;
        email = googleUser.email;
        body = {
          "username": username,
          "email": email,
          "password": password,
          "auth_type": signInType[AuthType.google]!
        };
        final photoUrl = googleUser.photoUrl;
        if (photoUrl != null) await _uploadGoogleProfileImage(photoUrl);
      case AuthType.facebook:
        final LoginResult result =
            await _facebookAuth.login(permissions: ['email']);
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
      userId = json.decode(response.body)['id'];
      return true;
    }
    return false;
  }

  Future<Uint8List> cropToSquare(Uint8List imageBytes) async {
    final codec = await instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    int width = image.width;
    int height = image.height;
    int newSize = width < height ? width : height;

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, newSize.toDouble(), newSize.toDouble()),
      Rect.fromLTWH(0, 0, newSize.toDouble(), newSize.toDouble()),
      paint,
    );

    final croppedImage = await recorder.endRecording().toImage(newSize, newSize);
    final byteData = await croppedImage.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _uploadGoogleProfileImage(String photoUrl) async {
    final response = await http.get(Uri.parse(photoUrl));
    if (response.statusCode == 200) {
      Uint8List imageBytes = response.bodyBytes;
      Uint8List croppedImage = await cropToSquare(imageBytes);

      var request = http.MultipartRequest('POST', Uri.parse("$apiUrl/upload_avatar/$userId"));
      request.files.add(http.MultipartFile.fromBytes(
          'file',
          croppedImage,
          filename: 'image$userId.png')
      );
      var streamedResponse = await request.send();
      await http.Response.fromStream(streamedResponse);
    } else {
      log("Failed to download Google profile image");
    }
  }

  Future<bool> checkAuthType(authType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('sign_in_method') == signInType[authType];
  }
}
