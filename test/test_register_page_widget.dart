import 'package:coordimate/keys.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coordimate/pages/register_page.dart';

@GenerateMocks([http.Client])
void main() {
  testWidgets('RegisterPage has input fields and buttons', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: RegisterPage(),
    ));

    final nameFinder = find.text('Name');
    final emailFinder = find.text('E-mail');
    final passwordFinder = find.text('Password');
    final confirmPasswordFinder = find.text('Confirm Password');
    final registerButtonFinder = find.text('Register');
    final logInButtonFinder = find.text('Log In');

    expect(nameFinder, findsOneWidget);
    expect(emailFinder, findsOneWidget);
    expect(passwordFinder, findsOneWidget);
    expect(confirmPasswordFinder, findsOneWidget);
    expect(registerButtonFinder, findsOneWidget);
    expect(logInButtonFinder, findsOneWidget);
  });

  testWidgets("User can't register if email not inserted", (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: RegisterPage(),
    ));

    var enterNameFinder = find.text('Please enter name');
    expect(enterNameFinder, findsNothing);

    final client = MockClient((_) async => http.Response(
        '{"id": "123", "username": "John", "password": "pwd", "fcm_token": "no_token", "email": "test@mail.com", "meetings": [], "schedule": [], "groups": []}',
        200));
    await tester.tap(find.text('Register'));

    enterNameFinder = find.text('Please enter name');
    expect(enterNameFinder, findsOneWidget);
  });
}
