import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';

import 'package:coordimate/keys.dart';
import 'package:coordimate/data/storage.dart';

class AuthInterceptor implements InterceptorContract {
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

class ExpiredTokenRetryPolicy extends RetryPolicy {
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
        print("Failed to refresh token response code ${response.statusCode}");
        return false;
      }
    }
    return false;
  }
}

Client client = InterceptedClient.build(
    interceptors: [AuthInterceptor()], retryPolicy: ExpiredTokenRetryPolicy());
