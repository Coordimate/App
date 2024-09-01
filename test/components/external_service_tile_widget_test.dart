import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/external_service_tile.dart';
import 'package:coordimate/components/meeting_tiles.dart';
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/pages/meeting_info_page.dart';
import 'package:coordimate/pages/meetings_archive.dart';
import 'package:coordimate/pages/meetings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/client/meetings.dart';
import '../test.mocks.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:mockito/mockito.dart';

void main() {
  late MockAuthorizationController mockAuthorizationController;

  setUp(() {
    mockAuthorizationController = MockAuthorizationController();

    AppState.testMode = true;
  });

  testWidgets('SquareTile displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SquareTile(
            imagePath: 'lib/images/google.png',
            authType: AuthType.google
        ),
      ),
    ));

    await tester.pumpAndSettle();

    // Verify that the SquareTile widget is displayed
    expect(find.byType(SquareTile), findsOneWidget);
  });

}
