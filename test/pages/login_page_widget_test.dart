import 'package:coordimate/app_state.dart';
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:coordimate/pages/login_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import '../helpers/when.dart';
import '../test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LoginPage has input fields and buttons', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: LoginPage(),
    ));

    expect(find.byKey(emailFieldKey), findsOneWidget);
    expect(find.byKey(passwordFieldKey), findsOneWidget);

    expect(find.byKey(loginButtonKey), findsOneWidget);
    expect(find.byKey(registerButtonKey), findsOneWidget);

    expect(find.byKey(googleTileKey), findsOneWidget);
    expect(find.byKey(facebookTileKey), findsOneWidget);
  });

  testWidgets('Redirect to RegisterPage', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: LoginPage(),
    ));

    expect(find.byKey(registerButtonKey), findsOneWidget);

    await tester.tap(find.byKey(registerButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(emailFieldKey), findsOneWidget);
    expect(find.byKey(passwordFieldKey), findsOneWidget);
    expect(find.byKey(confirmPasswordFieldKey), findsOneWidget);
    expect(find.byKey(usernameFieldKey), findsOneWidget);
    expect(find.byKey(registerButtonKey), findsOneWidget);
    expect(find.byKey(loginButtonKey), findsOneWidget);
    expect(find.byKey(googleTileKey), findsOneWidget);
    expect(find.byKey(facebookTileKey), findsOneWidget);
  });

  group('Unfilled text fields', () {
    testWidgets("User can't login if email not inserted", (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: LoginPage(),
      ));

      var enterEmailFinder = find.text('Please enter e-mail');
      expect(enterEmailFinder, findsNothing);
      
      await tester.tap(find.byKey(loginButtonKey));

      await tester.pumpAndSettle();

      enterEmailFinder = find.text('Please enter e-mail');
      expect(enterEmailFinder, findsOneWidget);
    });

    testWidgets("User can't login if password not inserted", (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: LoginPage(),
      ));

      var enterPswdFinder = find.text('Please enter password');
      expect(enterPswdFinder, findsNothing);
      
      await tester.tap(find.byKey(loginButtonKey));

      await tester.pumpAndSettle();

      enterPswdFinder = find.text('Please enter password');
      expect(enterPswdFinder, findsOneWidget);
    });
  });

  group('Login flows', () {
    testWidgets('Failed email login due to incorrect credentials', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: LoginPage(),
      ));

      expect(find.byKey(alertDialogKey), findsNothing);

      final emailFieldFinder = find.byKey(emailFieldKey);
      final passwordFieldFinder = find.byKey(passwordFieldKey);
      await tester.enterText(emailFieldFinder, 'user@example.com');
      await tester.enterText(passwordFieldFinder, 'password123');
      await tester.pumpAndSettle();

      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);

      await tester.tap(find.byKey(loginButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(alertDialogKey), findsOneWidget);
      expect(find.text('Sign In Failed'), findsOneWidget);
      expect(find.byKey(okButtonKey), findsOneWidget);

      await tester.tap(find.byKey(okButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(alertDialogKey), findsNothing);
    });

    testWidgets('Successful login and rendering meetings page', (tester) async {
      final client = MockClient();
      final storage = MockFlutterSecureStorage();
      final sharedPrefs = MockSharedPreferences();
      final firebase = MockFirebaseMessaging();

      await tester.pumpWidget(const MaterialApp(
        home: LoginPage(),
      ));
      AppState.authController = AuthorizationController(
          plainClient: client,
      );
      AppState.storage = storage;
      AppState.prefs = Future.value(sharedPrefs);
      AppState.client = client;
      AppState.firebaseMessagingInstance = firebase;

      when(storage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      when(storage.read(key: anyNamed('key')))
          .thenAnswer((_) async => "value");

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

      when(client.get(
        Uri.parse('$apiUrl/meetings'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{"meetings": [{"id": "1", "title": "meeting ","start": "2024-07-09T13:10:00.000","group": {"id": "2","name": "group"},"status": "accepted","is_finished": true}]}', 200));

      when(sharedPrefs.setString(any, any)).thenAnswer((_) async => true);

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

      expect(find.byKey(alertDialogKey), findsNothing);

      final emailFieldFinder = find.byKey(emailFieldKey);
      final passwordFieldFinder = find.byKey(passwordFieldKey);
      await tester.enterText(emailFieldFinder, 'user@example.com');
      await tester.enterText(passwordFieldFinder, 'password123');
      await tester.pumpAndSettle();

      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);

      await tester.tap(find.byKey(loginButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(alertDialogKey), findsNothing);

      expect(find.text('Meetings'), findsAtLeast(1));
    });

    testWidgets('Failed login through google', (tester) async {
      final mockAuthController = MockAuthorizationController();
      AppState.authController = mockAuthController;

      when(mockAuthController.signIn("", AuthType.google)).thenAnswer((_) async => false);

      await tester.pumpWidget(const MaterialApp(
        home: LoginPage(),
      ));

      expect(find.byKey(googleTileKey), findsOneWidget);

      await tester.tap(find.byKey(googleTileKey));
      await tester.pumpAndSettle();

      verify(mockAuthController.signIn("", AuthType.google)).called(1);
    });

    testWidgets('Successful login through google', (tester) async {
      final mockAuthController = MockAuthorizationController();
      final firebase = MockFirebaseMessaging();

      AppState.authController = mockAuthController;
      AppState.firebaseMessagingInstance = firebase;

      when(mockAuthController.signIn("", AuthType.google)).thenAnswer((_) async => true);
      whenFirebase(firebase);

      await tester.pumpWidget(const MaterialApp(
        home: LoginPage(),
      ));

      expect(find.byKey(googleTileKey), findsOneWidget);

      await tester.tap(find.byKey(googleTileKey));
      await tester.pumpAndSettle();

      expect(find.text("Meetings"), findsExactly(2));

      verify(mockAuthController.signIn("", AuthType.google)).called(1);
    });

    testWidgets('Failed login through facebook', (tester) async {
      final mockAuthController = MockAuthorizationController();
      AppState.authController = mockAuthController;

      when(mockAuthController.signIn("", AuthType.facebook)).thenAnswer((_) async => false);

      await tester.pumpWidget(const MaterialApp(
        home: LoginPage(),
      ));

      expect(find.byKey(facebookTileKey), findsOneWidget);

      await tester.tap(find.byKey(facebookTileKey));
      await tester.pumpAndSettle();

      verify(mockAuthController.signIn("", AuthType.facebook)).called(1);
    });

    testWidgets('Successful login through facebook', (tester) async {
      final mockAuthController = MockAuthorizationController();
      final firebase = MockFirebaseMessaging();

      AppState.authController = mockAuthController;
      AppState.firebaseMessagingInstance = firebase;

      when(mockAuthController.signIn("", AuthType.facebook)).thenAnswer((_) async => true);
      whenFirebase(firebase);

      await tester.pumpWidget(const MaterialApp(
        home: LoginPage(),
      ));

      expect(find.byKey(facebookTileKey), findsOneWidget);

      await tester.tap(find.byKey(facebookTileKey));
      await tester.pumpAndSettle();

      expect(find.text("Meetings"), findsExactly(2));

      verify(mockAuthController.signIn("", AuthType.facebook)).called(1);
    });
  });
}
