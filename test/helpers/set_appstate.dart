import 'package:coordimate/app_state.dart';
import 'package:coordimate/controllers/auth_controller.dart';

void setAppState(client, storage, sharedPrefs, firebase) {
  AppState.authController = AuthorizationController(
    plainClient: client,
  );
  AppState.storage = storage;
  AppState.prefs = Future.value(sharedPrefs);
  AppState.client = client;
  AppState.firebaseMessagingInstance = firebase;
}