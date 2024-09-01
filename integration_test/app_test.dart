import 'package:coordimate/app_state.dart';
import 'package:coordimate/pages/login_page.dart';
import 'package:coordimate/pages/start_page.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coordimate/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Test login',
        (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // We are on the start page, and we choose to log in
      expect(find.byType(StartPage), findsOne);
      final loginButton = find.text('Log In');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      AppState.testMode = true;

      // We get to Login page, input email and password of a test user
      expect(find.byType(LoginPage), findsOne);
      final emailFieldFinder = find.byKey(emailFieldKey);
      final passwordFieldFinder = find.byKey(passwordFieldKey);
      await tester.enterText(emailFieldFinder, 'user@mail.com');
      await tester.enterText(passwordFieldFinder, 'user');
      await tester.pumpAndSettle();
      expect(find.text('user@mail.com'), findsOneWidget);
      expect(find.text('user'), findsOneWidget);
      await tester.tap(find.byKey(loginButtonKey));
      expect(find.byKey(alertDialogKey), findsNothing);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Navigate to schedule page
      await tester.tap(find.text("Schedule"));
      await tester.pumpAndSettle();
    });
  });
}
