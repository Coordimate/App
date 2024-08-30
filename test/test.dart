import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/controllers/group_controller.dart';
import 'package:coordimate/controllers/meeting_controller.dart';
import 'package:coordimate/controllers/schedule_controller.dart';
import 'package:coordimate/controllers/user_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([
  http.Client,
  FlutterSecureStorage,
  SharedPreferences,
  FirebaseMessaging,

  MeetingController,
  AuthorizationController,
  UserController,
  GroupController,
  ScheduleController
])
void main() {}