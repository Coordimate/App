import 'package:coordimate/app_state.dart';
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:coordimate/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'login_page_widget_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
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
      final client = MockClient();
      AppState.authController.client = client;
      await tester.pumpWidget(const MaterialApp(
        home: LoginPage(),
      ));

      expect(find.byKey(alertDialogKey), findsNothing);

      when(client.post(
        Uri.parse('API_URL/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{"error": "Incorrect credentials"}', 400));

      final emailFieldFinder = find.byKey(emailFieldKey);
      final passwordFieldFinder = find.byKey(passwordFieldKey);
      await tester.enterText(emailFieldFinder, 'user@example.com');
      await tester.enterText(passwordFieldFinder, 'password123');
      await tester.pumpAndSettle();

      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);

      await tester.tap(find.byKey(loginButtonKey));
      await tester.pumpAndSettle();

      final result = await AppState.authController.signIn("email", AuthType.email, password: "password");
      expect(result, false);

      expect(find.byKey(alertDialogKey), findsOneWidget);
      expect(find.text('Sign In Failed'), findsOneWidget);
      expect(find.byKey(okButtonKey), findsOneWidget);

      await tester.tap(find.byKey(okButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(alertDialogKey), findsNothing);
    });

    testWidgets('Successful login and rendering meetings page', (tester) async {
      final client = MockClient();
      AppState.authController.client = client;
      await tester.pumpWidget(const MaterialApp(
        home: LoginPage(),
      ));

      expect(find.byKey(alertDialogKey), findsNothing);

      when(client.post(
        Uri.parse('API_URL/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{"access_token": "1", "refresh_token": "1"}', 200));

      final emailFieldFinder = find.byKey(emailFieldKey);
      final passwordFieldFinder = find.byKey(passwordFieldKey);
      await tester.enterText(emailFieldFinder, 'user@example.com');
      await tester.enterText(passwordFieldFinder, 'password123');
      await tester.pumpAndSettle();

      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);

      final result = await AppState.authController.signIn("email", AuthType.email, password: "password");
      expect(result, true);

      await tester.tap(find.byKey(loginButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(alertDialogKey), findsNothing);

      expect(find.byKey(emailFieldKey), findsOneWidget);
      expect(find.byKey(passwordFieldKey), findsOneWidget);
      expect(find.byKey(confirmPasswordFieldKey), findsOneWidget);
      expect(find.byKey(usernameFieldKey), findsOneWidget);
      expect(find.byKey(registerButtonKey), findsOneWidget);
      expect(find.byKey(loginButtonKey), findsOneWidget);
      expect(find.byKey(googleTileKey), findsOneWidget);
      expect(find.byKey(facebookTileKey), findsOneWidget);
    });
  });
}