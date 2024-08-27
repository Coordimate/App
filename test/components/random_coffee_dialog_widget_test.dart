import 'dart:convert';
import 'package:coordimate/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'random_coffee_dialog_widget_test.mocks.dart';

import 'package:coordimate/app_state.dart';
import 'package:coordimate/models/user.dart';
import 'package:coordimate/components/random_coffee_dialog.dart';
import '../helpers/set_appstate.dart';
import '../helpers/when.dart';

@GenerateMocks(
    [http.Client, FlutterSecureStorage, SharedPreferences, FirebaseMessaging])
void main() {
  final firebase = MockFirebaseMessaging();
  final client = MockClient();
  final storage = MockFlutterSecureStorage();
  final sharedPrefs = MockSharedPreferences();

  setAppState(client, storage, sharedPrefs, firebase);
  whenStatements(client, storage, sharedPrefs, firebase);

  testWidgets('RandomCoffeeDialog displays correctly',
      (WidgetTester tester) async {
    final RandomCoffee randomCoffee = RandomCoffee(
      startTime: const TimeOfDay(hour: 10, minute: 0),
      endTime: const TimeOfDay(hour: 18, minute: 0),
      isEnabled: true,
    );

    await tester.pumpWidget(
        MaterialApp(home: RandomCoffeeDialog(randomCoffee: randomCoffee)));

    expect(find.text('Random Coffee'), findsOneWidget);
    expect(find.text('Starting from'), findsOneWidget);
    expect(find.text('Up to'), findsOneWidget);
  });

  testWidgets('Enable/disable Random Coffee', (WidgetTester tester) async {
    final RandomCoffee randomCoffee = RandomCoffee(
      startTime: const TimeOfDay(hour: 10, minute: 0),
      endTime: const TimeOfDay(hour: 18, minute: 0),
      isEnabled: false,
    );

    await tester.pumpWidget(
        MaterialApp(home: RandomCoffeeDialog(randomCoffee: randomCoffee)));
    await tester.pumpAndSettle();

    expect(
        find.text('The feature is disabled. Toggle the switch to participate.'),
        findsOneWidget);

    // Tap the switch to enable
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.textContaining('The feature is disabled.'), findsNothing);
  });

  testWidgets('Show Flushbar on invalid time selection',
      (WidgetTester tester) async {
    final RandomCoffee randomCoffee = RandomCoffee(
      startTime: const TimeOfDay(hour: 10, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      isEnabled: true,
    );

    await tester.pumpWidget(
        MaterialApp(home: RandomCoffeeDialog(randomCoffee: randomCoffee)));

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(
        find.text(
            'Start time of the interval must be earlier than the end time'),
        findsOneWidget);
  });

  testWidgets('Calls updateRandomCoffee on Save', (WidgetTester tester) async {
    final RandomCoffee randomCoffee = RandomCoffee(
      startTime: const TimeOfDay(hour: 10, minute: 0),
      endTime: const TimeOfDay(hour: 18, minute: 0),
      isEnabled: true,
    );

    AppState.authController.userId = '12345';
    when(client.patch(Uri.parse("$apiUrl/users/12345"),
            headers: <String, String>{"Content-Type": "application/json"},
            body: anyNamed('body')))
        .thenAnswer((request) async => http.Response("ok", 200));

    await tester.pumpWidget(
        MaterialApp(home: RandomCoffeeDialog(randomCoffee: randomCoffee)));

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(client.patch(Uri.parse("$apiUrl/users/12345"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "random_coffee": {
                "is_enabled": true,
                "start_time": "10:0",
                "end_time": "18:0",
                "timezone": "120"
              }
            }),
            encoding: null))
        .called(1);
  });

  testWidgets('Time picker buttons open a dialog to pick time',
      (WidgetTester tester) async {
    final RandomCoffee randomCoffee = RandomCoffee(
      startTime: const TimeOfDay(hour: 10, minute: 0),
      endTime: const TimeOfDay(hour: 18, minute: 0),
      isEnabled: true,
    );

    await tester.pumpWidget(
        MaterialApp(home: RandomCoffeeDialog(randomCoffee: randomCoffee)));

    await tester.tap(find.textContaining('10:00'));
    await tester.pumpAndSettle();

    expect(find.byType(TimePickerDialog), findsOne);
  });
}
