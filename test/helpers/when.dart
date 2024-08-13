import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:coordimate/keys.dart';
import 'package:mockito/mockito.dart';

import 'client/meetings.dart';

void whenStorage(storage) {
  when(storage.write(key: anyNamed('key'), value: anyNamed('value')))
      .thenAnswer((_) async => {});

  when(storage.read(key: anyNamed('key')))
      .thenAnswer((_) async => "value");
}

void whenClient(client) {
  when(client.post(
    Uri.parse('$apiUrl/enable_notifications'),
    headers: anyNamed('headers'),
    body: anyNamed('body'),
  )).thenAnswer((_) async => http.Response('{"access_token": "1", "refresh_token": "1"}', 200));

  when(client.post(
    Uri.parse('$apiUrl/login'),
    headers: anyNamed('headers'),
    body: anyNamed('body'),
  )).thenAnswer((_) async => http.Response('{"access_token": "1", "refresh_token": "1"}', 200));

  when(client.get(
    Uri.parse('$apiUrl/me'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"id": "1", "email": "user@example.com"}', 200));
}

void whenSharedPrefs(sharedPrefs) {
  when(sharedPrefs.setString(any, any)).thenAnswer((_) async => true);
}

void whenFirebase(firebase) {
  when(firebase.requestPermission()).thenAnswer((_) async => const NotificationSettings(
    authorizationStatus: AuthorizationStatus.authorized,
    alert: AppleNotificationSetting.enabled,
    announcement: AppleNotificationSetting.enabled,
    badge: AppleNotificationSetting.enabled,
    carPlay: AppleNotificationSetting.enabled,
    criticalAlert: AppleNotificationSetting.enabled,
    lockScreen: AppleNotificationSetting.enabled,
    notificationCenter: AppleNotificationSetting.enabled,
    showPreviews: AppleShowPreviewSetting.always,
    sound: AppleNotificationSetting.enabled,
    timeSensitive: AppleNotificationSetting.enabled,
  ));
  when(firebase.getToken()).thenAnswer((_) async => 'fake_fcm_token');
  when(firebase.onTokenRefresh).thenAnswer((_) => Stream.fromIterable(['fake_fcm_token']));
}

void whenStatements(client, storage, sharedPrefs, firebase) {
  whenStorage(storage);
  whenClient(client);
  whenMeetingsNone(client);
  whenSharedPrefs(sharedPrefs);
  whenFirebase(firebase);
}