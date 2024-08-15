import 'package:coordimate/keys.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

void whenGroupsNone(client) {
  when(client.get(
    Uri.parse('$apiUrl/groups'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"groups": []}', 200));
}

const groupCard = {
  '"id": "group_id", "admin": {"_id": "admin_id", "username": "admin"}, "name": "name","description": "description","users": [],"meetings": [],"schedule": []'
};

void whenGroupsOne(client) {
  when(client.get(
    Uri.parse('$apiUrl/groups'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"groups" : [$groupCard]}', 200));
}
