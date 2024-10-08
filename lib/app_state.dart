import 'package:coordimate/controllers/schedule_controller.dart';
import 'package:coordimate/integrations/google_calendar_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/controllers/meeting_controller.dart';
import 'package:coordimate/controllers/user_controller.dart';
import 'package:coordimate/controllers/group_controller.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coordimate/auth_interceptor.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AppState {
  static Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  static FlutterSecureStorage storage = const FlutterSecureStorage();
  static http.Client client = InterceptedClient.build(
      interceptors: [AuthInterceptor(storage: storage)],
      retryPolicy: ExpiredTokenRetryPolicy(storage: storage));
  static AuthorizationController authController =
      AuthorizationController(plainClient: http.Client());
  static FirebaseMessaging firebaseMessagingInstance =
      FirebaseMessaging.instance;
  static MeetingController meetingController = MeetingController();
  static ScheduleController scheduleController = ScheduleController();
  static UserController userController = UserController();
  static GroupController groupController = GroupController();
  static WebSocketChannel? webSocketChannel;

  static bool testMode = false;

  static final googleCalendarClient = CalendarClient();
}
