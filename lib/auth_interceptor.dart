import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_interceptor/models/interceptor_contract.dart';
import 'package:http_interceptor/models/retry_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'keys.dart';

class AuthInterceptor implements InterceptorContract {
  AuthInterceptor({required this.storage});

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

class ExpiredTokenRetryPolicy extends RetryPolicy {
  ExpiredTokenRetryPolicy({required this.storage});

  final FlutterSecureStorage storage;

  @override
  int get maxRetryAttempts => 1;

  @override
  Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
    if (response.statusCode == 403) {
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
