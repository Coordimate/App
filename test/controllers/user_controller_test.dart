import 'package:coordimate/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:coordimate/controllers/user_controller.dart';
import 'package:coordimate/app_state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/when.dart';
import '../test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('UserController Tests', () {
    late MockClient client;
    late UserController userController;
    late MockFlutterSecureStorage storage;

    setUp(() {
      client = MockClient();
      storage = MockFlutterSecureStorage();

      AppState.client = client;
      AppState.storage = storage;
      userController = UserController();

      whenStorage(storage);
    });

    test('getInfo returns User object when API call is successful', () async {
      const userId = 'value';
      const userJson = '{"id": "$userId", "username": "test_user", "auth_type": "email", "email": "email@email.com"}';
      when(AppState.authController.getAccountId()).thenAnswer((_) async => userId);
      when(client.get(Uri.parse('$apiUrl/users/$userId'),
          headers: {"Content-Type": "application/json"}))
          .thenAnswer((_) async => http.Response(userJson, 200));
      final user = await userController.getInfo();

      expect(user.id, userId);
      expect(user.username, 'test_user');
    });

    test('getInfo throws exception when API call fails', () async {
      const userId = 'test_user_id';
      when(AppState.authController.getAccountId()).thenAnswer((_) async => userId);
      when(client.get(Uri.parse('$apiUrl/users/$userId'),
          headers: {"Content-Type": "application/json"}))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(() async => await userController.getInfo(), throwsException);
    });

    test('setFcmToken sends correct request', () async {
      const fcmToken = 'test_fcm_token';
      when(client.post(Uri.parse('$apiUrl/enable_notifications'),
          headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('', 200));

      await userController.setFcmToken(fcmToken);

      verify(client.post(Uri.parse('$apiUrl/enable_notifications'),
          headers: {"Content-Type": "application/json"},
          body: json.encode({'fcm_token': fcmToken})))
          .called(1);
    });

    test('changeUsername sends correct request and handles success', () async {
      const userId = 'test_user_id';
      const username = 'new_username';
      when(client.patch(Uri.parse('$apiUrl/users/$userId'),
          headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('', 200));

      await userController.changeUsername(username, userId);

      verify(client.patch(Uri.parse('$apiUrl/users/$userId'),
          headers: {"Content-Type": "application/json"},
          body: json.encode({'username': username})))
          .called(1);
    });

    test('changeUsername throws exception on failure', () async {
      const userId = 'test_user_id';
      const username = 'new_username';
      when(client.patch(Uri.parse('$apiUrl/users/$userId'),
          headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Error', 500));

      expect(() async => await userController.changeUsername(username, userId),
          throwsException);
    });

    test('deleteUser sends correct request and handles success', () async {
      const userId = 'test_user_id';
      when(client.delete(Uri.parse('$apiUrl/users/$userId'),
          headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('', 204));

      await userController.deleteUser(userId);

      verify(client.delete(Uri.parse('$apiUrl/users/$userId'),
          headers: {"Content-Type": "application/json"}))
          .called(1);
    });

    test('deleteUser throws exception on failure', () async {
      const userId = 'test_user_id';
      when(client.delete(Uri.parse('$apiUrl/users/$userId'),
          headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Error', 500));

      expect(() async => await userController.deleteUser(userId), throwsException);
    });

    test('sendChangePswdRequest sends correct request and handles success', () async {
      const newPswd = 'new_password';
      const oldPswd = 'old_password';
      when(client.post(Uri.parse('$apiUrl/change_password'),
          headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('', 201));

      final result = await userController.sendChangePswdRequest(newPswd, oldPswd);

      expect(result, isTrue);
    });

    test('sendChangePswdRequest returns false on 403 response', () async {
      const newPswd = 'new_password';
      const oldPswd = 'old_password';
      when(client.post(Uri.parse('$apiUrl/change_password'),
          headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('', 403));

      final result = await userController.sendChangePswdRequest(newPswd, oldPswd);

      expect(result, isFalse);
    });

    test('sendChangePswdRequest throws exception on other failures', () async {
      const newPswd = 'new_password';
      const oldPswd = 'old_password';
      when(client.post(Uri.parse('$apiUrl/change_password'),
          headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Error', 500));

      expect(() async => await userController.sendChangePswdRequest(newPswd, oldPswd),
          throwsException);
    });

    test('updateRandomCoffee sends correct request and handles success', () async {
      const userId = 'test_user_id';
      const data = 'random_coffee_data';
      when(client.patch(Uri.parse('$apiUrl/users/$userId'),
          headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('', 200));

      await userController.updateRandomCoffee(userId, data);

      verify(client.patch(Uri.parse('$apiUrl/users/$userId'),
          headers: {"Content-Type": "application/json"},
          body: json.encode({'random_coffee': data})))
          .called(1);
    });

    test('updateRandomCoffee throws exception on failure', () async {
      const userId = 'test_user_id';
      const data = 'random_coffee_data';
      when(client.patch(Uri.parse('$apiUrl/users/$userId'),
          headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Error', 500));

      expect(() async => await userController.updateRandomCoffee(userId, data),
          throwsException);
    });
  });
}