import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/external_service_tile.dart';
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    AppState.testMode = true;
  });

  testWidgets('SquareTile displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SquareTile(
            imagePath: 'lib/images/google.png', authType: AuthType.google),
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.byType(SquareTile), findsOneWidget);
  });
}
