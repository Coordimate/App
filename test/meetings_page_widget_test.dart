import 'package:coordimate/components/meeting_tiles.dart';
import 'package:coordimate/pages/meetings_page.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/client/meetings.dart';
import 'helpers/set_appstate.dart';
import 'helpers/when.dart';
import 'test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final firebase = MockFirebaseMessaging();
  final client = MockClient();
  final storage = MockFlutterSecureStorage();
  final sharedPrefs = MockSharedPreferences();

  setAppState(client, storage, sharedPrefs, firebase);
  whenStatements(client, storage, sharedPrefs, firebase);

  testWidgets('MeetingsPage is loaded', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MeetingsPage(),
    ));

    expect(find.text('Meetings'), findsOneWidget);
    expect(find.byKey(meetingsScrollViewKey), findsOneWidget);
    expect(find.byKey(draggableBottomSheetKey), findsOneWidget);
    expect(find.byKey(Key('calendarDayBox${DateTime.now().day.toString()}')), findsOneWidget);
    expect(find.byKey(Key('calendarDayBox${DateTime.now().add(const Duration(days: 1)).day.toString()}')), findsOneWidget);
    expect(find.byKey(Key('calendarDayBox${DateTime.now().add(const Duration(days: 2)).day.toString()}')), findsOneWidget);
    expect(find.byKey(Key('calendarDayBox${DateTime.now().add(const Duration(days: 3)).day.toString()}')), findsOneWidget);
    expect(find.byKey(Key('calendarDayBox${DateTime.now().add(const Duration(days: 4)).day.toString()}')), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byKey(archiveButtonKey), findsOneWidget);
  });

  testWidgets('MeetingsPage is loaded with no meetings', (tester) async {
    whenMeetingsNone(client);

    await tester.pumpWidget(const MaterialApp(
      home: MeetingsPage(),
    ));

    await tester.pumpAndSettle();
    
    expect(find.byKey(archiveButtonKey), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget.key.toString().contains('MeetingTile')), findsNothing);
  });

  testWidgets('MeetingsPage is loaded with one accepted meeting in the future', (tester) async {
    whenMeetingsOneAcceptedInTheFuture(client);

    await tester.pumpWidget(const MaterialApp(
      home: MeetingsPage(),
    ));

    await tester.pumpAndSettle();

    final meetingTile = find.byWidgetPredicate((widget) => widget.key.toString().contains('MeetingTile'));
    final acceptedMeetingTiles = meetingTile.evaluate().where((element) => element.widget is AcceptedMeetingTile).toList();

    expect(acceptedMeetingTiles.length, 1);
    expect(acceptedMeetingTiles.first.widget, isA<AcceptedMeetingTile>());
  });

  testWidgets('MeetingsPage is loaded with one invitation in the future', (tester) async {
    whenMeetingsOneInvitationInTheFuture(client);

    await tester.pumpWidget(const MaterialApp(
      home: MeetingsPage(),
    ));

    await tester.pumpAndSettle();

    final meetingTile = find.byWidgetPredicate((widget) => widget.key.toString().contains('MeetingTile'));
    final inviteMeetingTiles = meetingTile.evaluate().where((element) => element.widget is NewMeetingTile).toList();

    expect(inviteMeetingTiles.length, 1);
    expect(inviteMeetingTiles.first.widget, isA<NewMeetingTile>());
  });

  testWidgets('MeetingsPage is loaded with one declined meeting in the future', (tester) async {
    whenMeetingsOneDeclinedInTheFuture(client);

    await tester.pumpWidget(const MaterialApp(
      home: MeetingsPage(),
    ));

    await tester.pumpAndSettle();

    final meetingTile = find.byWidgetPredicate((widget) => widget.key.toString().contains('MeetingTile'));

    expect(meetingTile, findsNothing);
  });

  testWidgets('MeetingsPage is loaded with invitation and accepted in the future', (tester) async {
    whenMeetingsTwoAcceptedAndInvitationInTheFuture(client);

    await tester.pumpWidget(const MaterialApp(
      home: MeetingsPage(),
    ));

    await tester.pumpAndSettle();

    final meetingTiles = find.byWidgetPredicate((widget) => widget.key.toString().contains('MeetingTile'));
    final inviteMeetingTiles = meetingTiles.evaluate().where((element) => element.widget is NewMeetingTile).toList();
    final acceptedMeetingTiles = meetingTiles.evaluate().where((element) => element.widget is AcceptedMeetingTile).toList();

    expect(acceptedMeetingTiles.length, 1);
    expect(inviteMeetingTiles.length, 1);
    expect(acceptedMeetingTiles.first.widget, isA<AcceptedMeetingTile>());
    expect(inviteMeetingTiles.first.widget, isA<NewMeetingTile>());
  });
}
