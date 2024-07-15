import 'dart:developer';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

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
  AuthorizationController({required this.plainClient});

  final http.Client plainClient;
  late http.Client client = InterceptedClient.build(
      interceptors: [_AuthInterceptor(storage: storage)],
      retryPolicy: _ExpiredTokenRetryPolicy(storage: storage));

  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FacebookAuth _facebookAuth = FacebookAuth.instance;
  static const storage = FlutterSecureStorage();

  Future<String?> getAccountId() async {
    return await storage.read(key: 'id_account');
  }

  void signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? signInMethod = prefs.getString('sign_in_method');
    log("sign method: $signInMethod");

    storage.delete(key: 'refresh_token');
    storage.delete(key: 'access_token');

    prefs.remove('access_token');
    prefs.remove('refresh_token');

    if (signInMethod == signInType[AuthType.google]) {
      await _googleSignIn.signOut();
    } else if (signInMethod == signInType[AuthType.facebook]) {
      await _facebookAuth.logOut();
    }
  }

  Future<bool> signIn(email, signInMethod, {password}) async {
    Map<String, String> body;
    switch (signInMethod) {
      case AuthType.email:
        body = {
          "email": email,
          "password": password,
          "auth_type": signInType[AuthType.email]!
        };
      case AuthType.google:
        if (await _googleSignIn.isSignedIn()) await _googleSignIn.signOut();
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          log('Google User failed to sign in');
          return false;
        }
        final googleIdToken = (await googleUser.authentication).idToken;
        if (googleIdToken == null) return false;
        body = {
          "email": email,
          "google_id_token": googleIdToken,
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
          // TODO: add facebook token for verification on the backend
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

    await storage.write(key: 'access_token', value: accessToken);
    await storage.write(key: 'refresh_token', value: refreshToken);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('access_token', accessToken);
    prefs.setString('refresh_token', refreshToken);
    prefs.setString('sign_in_method', signInType[signInMethod]!);

    final meResponse = await client.get(Uri.parse('$apiUrl/me'));
    if (meResponse.statusCode != 200) {
      log("error requesting user account from /me");
      return false;
    }
    final respBody = json.decode(meResponse.body);
    await storage.write(key: 'id_account', value: respBody['id']);
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
        final googleIdToken = (await googleUser.authentication).idToken;
        if (googleIdToken == null) return false;
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
      await storage.write(key: 'access_token', value: accessToken);
      await storage.write(key: 'refresh_token', value: refreshToken);
    }
    final response = await client.get(Uri.parse('$apiUrl/me'));
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}

class _AuthInterceptor implements InterceptorContract {
  _AuthInterceptor({required this.storage});

  final FlutterSecureStorage storage;

  @override
  Future<bool> shouldInterceptRequest() async => true;

  @override
  Future<bool> shouldInterceptResponse() async => false;

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    String? accessToken = await storage.read(key: 'access_token');
    if (accessToken == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      accessToken = prefs.getString('access_token');
    }
    if (accessToken != null) {
      request.headers.addAll({
        'Authorization': 'Bearer $accessToken',
      });
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    return response;
  }
}

class _ExpiredTokenRetryPolicy extends RetryPolicy {
  _ExpiredTokenRetryPolicy({required this.storage});

  final FlutterSecureStorage storage;

  @override
  int get maxRetryAttempts => 1;

  @override
  Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
    if (response.statusCode == 403) {
      // Might be because of an expired token
      final String? refreshToken = await storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        return false;
      }
      final response = await http.post(Uri.parse("$apiUrl/refresh"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(<String, dynamic>{'refresh_token': refreshToken}));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String accessToken = data['access_token'];
        final String refreshToken = data['refresh_token'];
        await storage.write(key: 'access_token', value: accessToken);
        await storage.write(key: 'refresh_token', value: refreshToken);
        return true;
      } else {
        log("Failed to refresh token response code ${response.statusCode}");
        return false;
      }
    }
    return false;
  }
}
