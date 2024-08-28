import 'package:another_flushbar/flushbar.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/random_coffee_dialog.dart';
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/controllers/user_controller.dart';
import 'package:coordimate/models/user.dart';
import 'package:coordimate/pages/personal_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'helpers/client/data_provider.dart';
import 'personal_info_page_widget_test.mocks.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks(
    [AuthorizationController, UserController])
void main() {
  late MockAuthorizationController mockAuthController;
  late MockUserController mockUserController;

  final emailUser = User(
      id: '12345',
      email: DataProvider.email1,
      username: DataProvider.username1,
      password: 'password',
      authType: 'email',
      randomCoffee : RandomCoffee(
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 0),
        isEnabled: true,
      )
  );

  setUp(() {
    mockAuthController = MockAuthorizationController();
    mockUserController = MockUserController();

    AppState.authController = mockAuthController;
    AppState.userController = mockUserController;
    AppState.testMode = true;
  });

  group('User registered through email', () {

    testWidgets(
        'displays avatar, username, email, random coffee button, change password button, logout button, delete button', (
        WidgetTester tester) async {

      when(mockUserController.getInfo()).thenAnswer((_) async => emailUser);
      when(mockAuthController.checkAuthType(AuthType.email)).thenAnswer((_) async => true);

      await tester.pumpWidget(const MaterialApp(
        home: PersonalPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.text("Personal Page"), findsOneWidget);
      expect(find.byKey(avatarKey), findsOneWidget);
      expect(find.byKey(usernameFieldKey), findsOneWidget);
      expect(find.byKey(emailFieldKey), findsOneWidget);
      expect(find.byKey(randomCoffeeButtonKey), findsOneWidget);
      expect(find.byKey(changePasswordButtonKey), findsOneWidget);
      expect(find.byKey(logoutButtonKey), findsOneWidget);
      expect(find.byKey(deleteUserButtonKey), findsOneWidget);
    });

    testWidgets('change username', (WidgetTester tester) async {

      when(mockUserController.getInfo()).thenAnswer((_) async => emailUser);
      when(mockAuthController.checkAuthType(AuthType.email)).thenAnswer((_) async => true);
      when(mockUserController.changeUsername('newUsername', '12345')).thenAnswer((_) async {});

      await tester.pumpWidget(const MaterialApp(
        home: PersonalPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.byKey(usernameFieldKey), findsOneWidget);
      expect(find.text(emailUser.username), findsAtLeast(1));
      await tester.tap(find.byKey(editTextFieldButtonKey));
      await tester.enterText(find.byKey(usernameFieldKey), 'newUsername');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(editTextFieldButtonKey));
      await tester.pumpAndSettle();

      verify(mockUserController.changeUsername('newUsername', '12345')).called(1);
      expect(find.text('newUsername'), findsAtLeast(1));
    });

    testWidgets('open random coffee dialog and close', (WidgetTester tester) async {

      when(mockUserController.getInfo()).thenAnswer((_) async => emailUser);
      when(mockAuthController.checkAuthType(AuthType.email)).thenAnswer((_) async => true);

      await tester.pumpWidget(const MaterialApp(
        home: PersonalPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.byKey(randomCoffeeButtonKey), findsOneWidget);
      await tester.tap(find.byKey(randomCoffeeButtonKey));
      await tester.pumpAndSettle();
      expect(find.byType(RandomCoffeeDialog), findsOneWidget);
      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();
      expect(find.byType(RandomCoffeeDialog), findsNothing);
    });

    testWidgets('change password successfully', (WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      when(mockUserController.getInfo()).thenAnswer((_) async => emailUser);
      when(mockAuthController.checkAuthType(AuthType.email)).thenAnswer((_) async => true);
      when(mockUserController.sendChangePswdRequest('newPassword', 'password')).thenAnswer((_) async => true);

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const PersonalPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.byKey(changePasswordButtonKey), findsOneWidget);
      await tester.tap(find.byKey(changePasswordButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(oldPasswordFieldKey), findsOneWidget);
      expect(find.byKey(passwordFieldKey), findsOneWidget);
      expect(find.byKey(confirmPasswordFieldKey), findsOneWidget);
      await tester.enterText(find.byKey(oldPasswordFieldKey), 'password');
      await tester.enterText(find.byKey(passwordFieldKey), 'newPassword');
      await tester.enterText(find.byKey(confirmPasswordFieldKey), 'newPassword');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(yesButtonKey));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Password changed successfully'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(ChangePasswordDialog), findsNothing);

      verify(mockUserController.sendChangePswdRequest('newPassword', 'password')).called(1);
    });

    testWidgets('tries to change password but errors', (WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      when(mockUserController.getInfo()).thenAnswer((_) async => emailUser);
      when(mockAuthController.checkAuthType(AuthType.email)).thenAnswer((_) async => true);
      when(mockUserController.sendChangePswdRequest('newPassword', 'password')).thenAnswer((_) async => false);

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const PersonalPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.byKey(changePasswordButtonKey), findsOneWidget);
      await tester.tap(find.byKey(changePasswordButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(oldPasswordFieldKey), findsOneWidget);
      expect(find.byKey(passwordFieldKey), findsOneWidget);
      expect(find.byKey(confirmPasswordFieldKey), findsOneWidget);

      await tester.enterText(find.byKey(oldPasswordFieldKey), 'password');
      await tester.enterText(find.byKey(passwordFieldKey), 'newPassword');
      await tester.enterText(find.byKey(confirmPasswordFieldKey), 'newAnotherPassword');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(yesButtonKey));
      await tester.pump();
      expect(find.byType(Flushbar), findsAtLeast(1));
      expect(find.text('Passwords do not match'), findsOneWidget);

      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(passwordFieldKey), 'password');
      await tester.enterText(find.byKey(confirmPasswordFieldKey), 'password');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(yesButtonKey));
      await tester.pump();
      expect(find.byType(Flushbar), findsAtLeast(1));
      expect(find.text('New password is the same as the old one'), findsOneWidget);

      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(passwordFieldKey), 'newPassword');
      await tester.enterText(find.byKey(confirmPasswordFieldKey), 'newPassword');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(yesButtonKey));
      await tester.pump();
      expect(find.byType(Flushbar), findsAtLeast(1));
      expect(find.text('Old password is incorrect'), findsOneWidget);

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();

      expect(find.byKey(passwordFieldKey), findsNothing);

      verify(mockUserController.sendChangePswdRequest('newPassword', 'password')).called(1);
    });

    testWidgets('logs out and redirects to start page', (WidgetTester tester) async {
      when(mockUserController.getInfo()).thenAnswer((_) async => emailUser);
      when(mockAuthController.checkAuthType(AuthType.email)).thenAnswer((_) async => true);
      when(mockAuthController.signOut()).thenAnswer((_) async => {});
      when(mockAuthController.checkStoredToken()).thenAnswer((_) async => false);

      await tester.pumpWidget(const MaterialApp(
        home: PersonalPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.byKey(logoutButtonKey), findsOneWidget);
      await tester.tap(find.byKey(logoutButtonKey));
      await tester.pumpAndSettle();
      
      expect(find.text('Coordimate'), findsOne);
      
      verify(mockAuthController.signOut()).called(1);
    });

    testWidgets('delete user', (WidgetTester tester) async {
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
      when(mockUserController.getInfo()).thenAnswer((_) async => emailUser);
      when(mockAuthController.checkAuthType(AuthType.email)).thenAnswer((_) async => true);
      when(mockUserController.deleteUser('12345')).thenAnswer((_) async => {});
      when(mockAuthController.checkStoredToken()).thenAnswer((_) async => false);

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const PersonalPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.byKey(deleteUserButtonKey), findsOneWidget);

      await tester.tap(find.byKey(deleteUserButtonKey));
      await tester.pumpAndSettle();
      expect(find.text('Do you want to delete your account?'), findsOne);
      await tester.tap(find.byKey(noButtonKey));
      await tester.pumpAndSettle();
      expect(find.text('Do you want to delete your account?'), findsNothing);

      await tester.tap(find.byKey(deleteUserButtonKey));
      await tester.pumpAndSettle();
      expect(find.text('Do you want to delete your account?'), findsOne);
      await tester.tap(find.byKey(yesButtonKey));

      await tester.pumpAndSettle();
      
      expect(find.byType(SnackBar), findsOne);
      expect(find.text('Account deleted successfully'), findsOneWidget);

      expect(find.text('Coordimate'), findsOne);

      verify(mockUserController.deleteUser('12345')).called(1);
    });
  });

}
