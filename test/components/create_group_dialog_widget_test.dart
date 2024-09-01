import 'package:coordimate/components/create_group_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:coordimate/widget_keys.dart';

import '../test.mocks.dart';

void main() {
  late MockGroupController mockGroupController;

  setUp(() {
    mockGroupController = MockGroupController();
  });

  testWidgets('renders CreateGroupDialog correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CreateGroupDialog(
            key: null,
            onCreateGroup: mockGroupController.createGroup,
            fetchGroups: mockGroupController.getGroups,
          ),
        ),
      ),
    );

    expect(find.text('Create Group'), findsOneWidget);
    expect(find.byKey(groupCreationNameFieldKey), findsOneWidget);
    expect(find.byKey(groupCreationDescriptionFieldKey), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('shows validation error when form is invalid', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CreateGroupDialog(
            key: null,
            onCreateGroup: mockGroupController.createGroup,
            fetchGroups: mockGroupController.getGroups,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Create'));
    await tester.pump();

    expect(find.text('Please enter a name'), findsOneWidget);
  });

  testWidgets('calls onCreateGroup and fetchGroups on successful form submission', (WidgetTester tester) async {
    when(mockGroupController.createGroup(any, any)).thenAnswer((_) async {});
    when(mockGroupController.getGroups()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CreateGroupDialog(
            key: null,
            onCreateGroup: mockGroupController.createGroup,
            fetchGroups: mockGroupController.getGroups,
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(groupCreationNameFieldKey), 'Test Group');
    await tester.enterText(find.byKey(groupCreationDescriptionFieldKey), 'Test Description');

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateGroupDialog), findsNothing);

    verify(mockGroupController.createGroup('Test Group', 'Test Description')).called(1);
    verify(mockGroupController.getGroups()).called(1);
  });

  testWidgets('cancels and closes dialog when Cancel button is pressed', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CreateGroupDialog(
            key: null,
            onCreateGroup: mockGroupController.createGroup,
            fetchGroups: mockGroupController.getGroups,
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(groupCreationNameFieldKey), 'Test Group');
    await tester.enterText(find.byKey(groupCreationDescriptionFieldKey), 'Test Description');

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateGroupDialog), findsNothing);
  });
}
