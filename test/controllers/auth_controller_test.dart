import 'package:coordimate/app_state.dart';
import 'package:coordimate/controllers/auth_controller.dart';
import 'package:coordimate/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import '../test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthController Tests', () {
    late MockClient client;
    late MockFlutterSecureStorage storage;
    late MockSharedPreferences sharedPrefs;
    late AuthorizationController authController;

    setUp(() {
      client = MockClient();
      storage = MockFlutterSecureStorage();
      sharedPrefs = MockSharedPreferences();
      authController = AuthorizationController(
        plainClient: client,
      );
      AppState.storage = storage;
      AppState.prefs = Future.value(sharedPrefs);
      AppState.client = client;
    });

    test('Failed email login due to incorrect credentials', () async {

      when(client.post(
        Uri.parse('$apiUrl/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{"error": "Incorrect credentials"}', 400));

      final result = await authController.signIn("email", AuthType.email, password: "password");
      expect(result, false);
    });

    test('Failed registration due to existing user', () async {

      when(client.post(
        Uri.parse('$apiUrl/register'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{"detail": "User already exists"}', 409));

      final result = await authController.register("email@example.com", "John Doe", AuthType.email, password: "password");
      expect(result, false);
    });

    test('Successful signing in', () async {

      when(storage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      when(storage.read(key: anyNamed('key')))
          .thenAnswer((_) async => "value");

      when(client.post(
        Uri.parse('$apiUrl/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{"access_token": "1", "refresh_token": "1"}', 200));

      when(client.get(
        Uri.parse('$apiUrl/me'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{"id": "1", "email": "user@example.com"}', 200));

      when(sharedPrefs.setString(any, any)).thenAnswer((_) async => true);

      final result = await authController.signIn("email", AuthType.email, password: "password");

      expect(result, true);
    });

    test('Successful registration', () async {

      when(storage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      when(storage.read(key: anyNamed('key')))
          .thenAnswer((_) async => "value");

      when(client.post(
        Uri.parse('$apiUrl/register'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{"id": "1","username": "John Doe","password": "password123","fcm_token": "notoken","email": "john@doe.com","meetings": [],"schedule": []"groups": []}', 201));

      when(client.post(
        Uri.parse('$apiUrl/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{"access_token": "1", "refresh_token": "1"}', 200));

      when(client.get(
        Uri.parse('$apiUrl/me'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{"id": "1", "email": "user@example.com"}', 200));

      when(sharedPrefs.setString(any, any)).thenAnswer((_) async => true);

      final result = await authController.register("email@example.com", "username", AuthType.email, password: "password");

      expect(result, true);
    });

    group('AuthController checkStoredToken Tests', () {

      test('returns true when tokens are present and API call is successful', () async {
        when(sharedPrefs.getString('access_token')).thenReturn('access_token_value');
        when(sharedPrefs.getString('refresh_token')).thenReturn('refresh_token_value');
        when(storage.write(key: 'access_token', value: 'access_token_value')).thenAnswer((_) async => {});
        when(storage.write(key: 'refresh_token', value: 'refresh_token_value')).thenAnswer((_) async => {});
        when(client.get(Uri.parse('$apiUrl/me'))).thenAnswer((_) async => http.Response('{"id": "user_id"}', 200));

        final result = await authController.checkStoredToken();

        expect(result, true);
        verify(storage.write(key: 'access_token', value: 'access_token_value')).called(1);
        verify(storage.write(key: 'refresh_token', value: 'refresh_token_value')).called(1);
      });

      test('returns false when tokens are present but API call fails', () async {
        when(sharedPrefs.getString('access_token')).thenReturn('access_token_value');
        when(sharedPrefs.getString('refresh_token')).thenReturn('refresh_token_value');
        when(storage.write(key: 'access_token', value: 'access_token_value')).thenAnswer((_) async => {});
        when(storage.write(key: 'refresh_token', value: 'refresh_token_value')).thenAnswer((_) async => {});
        when(client.get(Uri.parse('$apiUrl/me'))).thenAnswer((_) async => http.Response('Error', 500));

        final result = await authController.checkStoredToken();

        expect(result, false);
      });

      test('returns false when tokens are not present', () async {
        when(sharedPrefs.getString('access_token')).thenReturn(null);
        when(sharedPrefs.getString('refresh_token')).thenReturn(null);
        when(client.get(Uri.parse('$apiUrl/me'))).thenAnswer((_) async => http.Response('Error', 500));

        final result = await authController.checkStoredToken();

        expect(result, false);
      });
    });

    group('AuthorizationController checkAuthType Tests', () {

      test('returns true when stored sign-in method matches provided authType', () async {
        when(sharedPrefs.getString('sign_in_method')).thenReturn(signInType[AuthType.google]);

        final result = await authController.checkAuthType(AuthType.google);

        expect(result, true);
      });

      test('returns false when stored sign-in method does not match provided authType', () async {
        when(sharedPrefs.getString('sign_in_method')).thenReturn(signInType[AuthType.facebook]);

        final result = await authController.checkAuthType(AuthType.google);

        expect(result, false);
      });

      test('returns false when no sign-in method is stored', () async {
        when(sharedPrefs.getString('sign_in_method')).thenReturn(null);

        final result = await authController.checkAuthType(AuthType.google);

        expect(result, false);
      });
    });

  });
}