import 'package:coordimate/controllers/schedule_controller.dart';
import 'package:http/http.dart' as http;
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/controllers/meeting_controller.dart';
import 'package:coordimate/controllers/user_controller.dart';

class  AppState {
  static final authController = AuthorizationController(plainClient: http.Client());
  static final meetingController = MeetingController();
  static final scheduleController = ScheduleController();
  static final userController = UserController();
}
