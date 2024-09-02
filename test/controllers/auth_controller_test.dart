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

  });
}