import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coordimate/components/text_field_with_edit.dart';
import 'package:coordimate/widget_keys.dart';

void main() {
  testWidgets('renders EditableTextField correctly', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditableTextField(
            controller: controller,
            focusNode: focusNode,
            onSubmit: (value) {},
          ),
        ),
      ),
    );

    expect(find.byType(EditableTextField), findsOneWidget);
  });

  testWidgets('shows placeholder text when controller is empty', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditableTextField(
            controller: controller,
            focusNode: focusNode,
            onSubmit: (value) {},
            placeHolderText: 'Enter text here',
          ),
        ),
      ),
    );

    expect(find.text('Enter text here'), findsOneWidget);
  });

  testWidgets('enters edit mode when edit icon is pressed', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditableTextField(
            controller: controller,
            focusNode: focusNode,
            onSubmit: (value) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(editTextFieldButtonKey));
    await tester.pumpAndSettle();

    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('submits text correctly', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    String submittedText = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditableTextField(
            controller: controller,
            focusNode: focusNode,
            onSubmit: (value) {
              submittedText = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(editTextFieldButtonKey));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Test text');
    await tester.tap(find.byKey(editTextFieldButtonKey));
    await tester.pumpAndSettle();

    expect(submittedText, 'Test text');
  });

  testWidgets('does nothing if new text is equal to previous', (tester) async {
    final controller = TextEditingController();
    controller.text = 'Test text';
    final focusNode = FocusNode();
    String submittedText = 'test';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditableTextField(
            controller: controller,
            focusNode: focusNode,
            onSubmit: (value) {
              submittedText = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(editTextFieldButtonKey));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Test text');
    await tester.tap(find.byKey(editTextFieldButtonKey));
    await tester.pumpAndSettle();

    expect(submittedText, 'test');
  });
}