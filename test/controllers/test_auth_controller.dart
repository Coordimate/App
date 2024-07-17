import 'package:coordimate/controllers/auth_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_auth_controller.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage, SharedPreferences])
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
        storage: storage,
        prefs: sharedPrefs,
        client: client
      );
    });

    test('Failed email login due to incorrect credentials', () async {

      when(client.post(
        Uri.parse('http://10.0.2.2:8000/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{"error": "Incorrect credentials"}', 400));

      final result = await authController.signIn("email", AuthType.email, password: "password");
      expect(result, false);
    });

    test('Successful signing in', () async {

      when(storage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      when(storage.read(key: anyNamed('key')))
          .thenAnswer((_) async => "value");

      when(client.post(
        Uri.parse('http://10.0.2.2:8000/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{"access_token": "1", "refresh_token": "1"}', 200));

      when(client.get(
        Uri.parse('http://10.0.2.2:8000/me'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{"id": "1", "email": "user@example.com"}', 200));

      when(sharedPrefs.setString(any, any)).thenAnswer((_) async => true);

      final result = await authController.signIn("email", AuthType.email, password: "password");

      expect(result, true);
    });

  });
}