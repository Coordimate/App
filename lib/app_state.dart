import 'dart:convert';
import 'dart:developer';
import 'package:coordimate/controllers/schedule_controller.dart';
import 'package:coordimate/integrations/google_calendar_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/controllers/meeting_controller.dart';
import 'package:coordimate/controllers/user_controller.dart';
import 'package:coordimate/controllers/group_controller.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:http_interceptor/models/interceptor_contract.dart';
import 'package:http_interceptor/models/retry_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'keys.dart';

class AppState {
  static Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  static FlutterSecureStorage storage = const FlutterSecureStorage();
  static http.Client client = InterceptedClient.build(
      interceptors: [_AuthInterceptor(storage: storage)],
      retryPolicy: _ExpiredTokenRetryPolicy(storage: storage));
  static AuthorizationController authController =
      AuthorizationController(plainClient: http.Client());
  static FirebaseMessaging firebaseMessagingInstance =
      FirebaseMessaging.instance;
  static final meetingController = MeetingController();
  static final scheduleController = ScheduleController();
  static final userController = UserController();
  static final groupController = GroupController();

  static bool testMode = false;

  static final googleCalendarClient = CalendarClient();
}

// TODO: make the class not private by removing the underscore and move it to another file
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
