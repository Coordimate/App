import 'package:coordimate/app_state.dart';
import 'package:coordimate/pages/start_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final firebase = MockFirebaseMessaging();
  final mockAuthController = MockAuthorizationController();

  testWidgets('logging in with stored token', (WidgetTester tester) async {
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

    when(mockAuthController.checkStoredToken()).thenAnswer((_) async => true);
    when(mockAuthController.trySilentGoogleSignIn()).thenAnswer((_) async => false);

    AppState.firebaseMessagingInstance = firebase;
    AppState.authController = mockAuthController;

    await tester.pumpWidget(const MaterialApp(
      home: StartPage(),
    ));

    await tester.pumpAndSettle();

    verify(mockAuthController.checkStoredToken()).called(1);
    verify(mockAuthController.trySilentGoogleSignIn()).called(1);

    expect(find.text("Archive"), findsOneWidget);
  });
}