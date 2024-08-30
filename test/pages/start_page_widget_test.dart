import 'package:coordimate/app_state.dart';
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/pages/start_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test.mocks.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:mockito/mockito.dart';

void main() {
  late MockAuthorizationController mockAuthController;

  setUp(() {
    mockAuthController = MockAuthorizationController();

    AppState.authController = mockAuthController;
    AppState.testMode = true;
  });

  group('Start page', () {

    testWidgets('displays app name, login and register buttons', (WidgetTester tester) async {

      when(mockAuthController.checkStoredToken()).thenAnswer((_) async => false);

      await tester.pumpWidget(const MaterialApp(
        home: StartPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.text("Coordimate"), findsOneWidget);
      expect(find.text("Log In"), findsOneWidget);
      expect(find.text("Register"), findsOneWidget);
      expect(find.byKey(googleTileKey), findsOneWidget);
      expect(find.byKey(facebookTileKey), findsOneWidget);
    });

    testWidgets('redirect to register page', (WidgetTester tester) async {

      when(mockAuthController.checkStoredToken()).thenAnswer((_) async => false);

      await tester.pumpWidget(const MaterialApp(
        home: StartPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.text("Register"), findsOneWidget);
      await tester.tap(find.text("Register"));
      await tester.pumpAndSettle();

      expect(find.text("Create Account"), findsOneWidget);
    });

    testWidgets('redirect to log in page', (WidgetTester tester) async {

      when(mockAuthController.checkStoredToken()).thenAnswer((_) async => false);

      await tester.pumpWidget(const MaterialApp(
        home: StartPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.text("Log In"), findsOneWidget);
      await tester.tap(find.text("Log In"));
      await tester.pumpAndSettle();

      expect(find.text("Welcome Back"), findsOneWidget);
    });

    testWidgets('sign in from google tile', (WidgetTester tester) async {

      when(mockAuthController.checkStoredToken()).thenAnswer((_) async => false);
      when(mockAuthController.signIn("", AuthType.google)).thenAnswer((_) async => true);

      await tester.pumpWidget(const MaterialApp(
        home: StartPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.byKey(googleTileKey), findsOneWidget);
      // await tester.tap(find.byKey(googleTileKey));
      // await tester.pumpAndSettle();

      // expect(find.text("Meetings"), findsOneWidget);
    });

    testWidgets('sign in from facebook tile', (WidgetTester tester) async {

      when(mockAuthController.checkStoredToken()).thenAnswer((_) async => false);
      when(mockAuthController.signIn("", AuthType.facebook)).thenAnswer((_) async => true);

      await tester.pumpWidget(const MaterialApp(
        home: StartPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.byKey(facebookTileKey), findsOneWidget);
      // await tester.tap(find.byKey(facebookTileKey));
      // await tester.pumpAndSettle();

      // expect(find.text("Meetings"), findsOneWidget);
    });

  });

}
