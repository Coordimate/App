import 'package:http/http.dart' as http;
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/controllers/meeting_controller.dart';

class  AppState {
  static final meetingController = MeetingController();
  static final authController = AuthorizationController(plainClient: http.Client());
}