import 'dart:convert';

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
    final String? accessToken = await storage.read(key: 'access_token');
    if (accessToken != null) {
      request.headers.addAll({'Authorization': 'Bearer $accessToken'});
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
      http.post(Uri.parse("$apiUrl/refresh"),
          body: json.encode(<String, dynamic>{'refresh_token': refreshToken}));
      return true;
    }
    return false;
  }
}

Client client = InterceptedClient.build(
    interceptors: [AuthInterceptor()], retryPolicy: ExpiredTokenRetryPolicy());
