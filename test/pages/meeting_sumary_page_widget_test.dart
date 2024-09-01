import 'package:coordimate/app_state.dart';
import 'package:coordimate/pages/meeting_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/client/data_provider.dart';
import '../test.mocks.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:mockito/mockito.dart';

void main() {
  late MockMeetingController mockMeetingController;

  setUp(() {
    mockMeetingController = MockMeetingController();

    AppState.meetingController = mockMeetingController;
    AppState.testMode = true;
  });

  testWidgets('open empty summary page', (WidgetTester tester) async {
    final meetingSummary = SummaryPage(
      id: DataProvider.meetingID1,
      summary: '',
    );

    await tester.pumpWidget(MaterialApp(
      home: meetingSummary,
    ));

    expect(find.byType(SummaryPage), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.byKey(sliderKey), findsOneWidget);
    expect(find.byKey(summaryTextFieldKey), findsOneWidget);
    expect(find.byKey(appBarIconButtonKey), findsOneWidget);
  });

  testWidgets('open filled summary page', (WidgetTester tester) async {
    final meetingSummary = SummaryPage(
      id: DataProvider.meetingID1,
      summary: DataProvider.meetingSummaryLong,
    );

    await tester.pumpWidget(MaterialApp(
      home: meetingSummary,
    ));

    expect(find.byType(SummaryPage), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text(DataProvider.meetingSummaryLong), findsOneWidget);
    expect(find.byKey(sliderKey), findsOneWidget);
    expect(find.byKey(summaryTextFieldKey), findsOneWidget);
    expect(find.byKey(appBarIconButtonKey), findsOneWidget);
  });

  testWidgets('fill empty summary page and save', (WidgetTester tester) async {
    when(mockMeetingController.saveSummary(DataProvider.meetingID1, DataProvider.meetingSummaryShort))
        .thenAnswer((_) async => {});
    final meetingSummary = SummaryPage(
      id: DataProvider.meetingID1,
      summary: '',
    );

    await tester.pumpWidget(MaterialApp(
      home: meetingSummary,
    ));

    expect(find.byKey(summaryTextFieldKey), findsOneWidget);

    await tester.enterText(find.byKey(summaryTextFieldKey), DataProvider.meetingSummaryShort);
    await tester.pumpAndSettle();

    expect(find.text(DataProvider.meetingSummaryShort), findsOneWidget);

    await tester.tap(find.byKey(appBarIconButtonKey));
    await tester.pumpAndSettle();

    verify(mockMeetingController.saveSummary(DataProvider.meetingID1, DataProvider.meetingSummaryShort)).called(1);
  });

  testWidgets('add text to filled summary page', (WidgetTester tester) async {
    const String addText = " Francesco Fergolini woooooooo";

    final meetingSummary = SummaryPage(
      id: DataProvider.meetingID1,
      summary: DataProvider.meetingSummaryShort,
    );

    await tester.pumpWidget(MaterialApp(
      home: meetingSummary,
    ));

    final textFieldFinder = find.byKey(summaryTextFieldKey);
    expect(textFieldFinder, findsOneWidget);

    final currentText = tester.widget<TextField>(textFieldFinder).controller?.text ?? '';

    final newText = currentText + addText;

    await tester.enterText(find.byKey(summaryTextFieldKey), newText);
    await tester.pumpAndSettle();
  });

  testWidgets('change font', (WidgetTester tester) async {
    final meetingSummary = SummaryPage(
      id: DataProvider.meetingID1,
      summary: DataProvider.meetingSummaryShort,
    );

    await tester.pumpWidget(MaterialApp(
      home: meetingSummary,
    ));

    final sliderFinder = find.byKey(sliderKey);
    expect(sliderFinder, findsOneWidget);

    final oldTextFinder = find.text(DataProvider.meetingSummaryShort);
    final oldFont = tester.widget<EditableText>(oldTextFinder).style.fontSize;

    await tester.drag(sliderFinder, const Offset(100, 0));
    await tester.pumpAndSettle();

    final newTextFinder = find.text(DataProvider.meetingSummaryShort);
    final newFont = tester.widget<EditableText>(newTextFinder).style.fontSize;

    expect(newFont! > oldFont!, true);
  });

  testWidgets('click in the middle of the screen and check if field is focused', (WidgetTester tester) async {
    final meetingSummary = SummaryPage(
      id: DataProvider.meetingID1,
      summary: DataProvider.meetingSummaryShort,
    );

    await tester.pumpWidget(MaterialApp(
      home: meetingSummary,
    ));

    final textFieldFinder = find.byKey(summaryTextFieldKey);
    expect(textFieldFinder, findsOneWidget);

    await tester.tapAt(const Offset(200, 200));
    await tester.pumpAndSettle();

    final focused = tester.widget<TextField>(textFieldFinder).focusNode?.hasFocus;
    expect(focused, true);
  });
}
