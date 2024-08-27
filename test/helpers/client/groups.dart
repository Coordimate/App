// test/helpers/client/groups
import 'package:coordimate/keys.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'data_provider.dart';

String groupName1 = DataProvider.getGroupName1();
String groupName2 = DataProvider.getGroupName2();
String groupDescr1 = DataProvider.getGroupDescr1();
String groupDescr2 = DataProvider.getGroupDescr2();
String longGroupDescr = DataProvider.getLongGroupDescr();
String longGroupName = DataProvider.getLongGroupName();

final groupCard1 = {
  '"id": "group_id", "admin": {"_id": "admin_id", "username": "admin"}, "name": "$groupName1","description": "$groupDescr1","users": [],"meetings": [],"schedule": []'
};
final groupCard2 = {
  '"id": "group_id", "admin": {"_id": "admin_id", "username": "admin"}, "name": "$groupName2","description": "$groupDescr2","users": [],"meetings": [],"schedule": []'
};
final groupCard3 = {
  '"id": "group_id", "admin": {"_id": "admin_id", "username": "admin"}, "name": "$groupName1","description": "$longGroupDescr","users": [],"meetings": [],"schedule": []'
};
final groupCard4 = {
  '"id": "group_id", "admin": {"_id": "admin_id", "username": "admin"}, "name": "$longGroupName","description": "$longGroupDescr","users": [],"meetings": [],"schedule": []'
};
void whenGroupsNone(client) {
  when(client.get(
    Uri.parse('$apiUrl/groups'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"groups": []}', 200));
}

void whenGroupsOne(client) {
  when(client.get(
    Uri.parse('$apiUrl/groups'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"groups" : [$groupCard1]}', 200));
}

void whenGroupsTwo(client) {
  when(client.get(
    Uri.parse('$apiUrl/groups'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async =>
      http.Response('{"groups" : [$groupCard1, $groupCard2]}', 200));
}

void whenGroupsLongOne(client) {
  when(client.get(
    Uri.parse('$apiUrl/groups'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"groups" : [$groupCard3]}', 200));
}

void whenGroupsLongNameAndDescr(client) {
  when(client.get(
    Uri.parse('$apiUrl/groups'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response('{"groups" : [$groupCard4]}', 200));
}

void whenCreateGroup(client) {
  when(client.post(
    Uri.parse('$apiUrl/groups'),
    headers: anyNamed('headers'),
    body: anyNamed('body'),
  )).thenAnswer((_) async => http.Response(
      '{"id": "group_id", "admin": {"_id": "admin_id", "username": "admin"}, "name": "$groupName1","description": "$groupDescr1","users": [],"meetings": [],"schedule": []}',
      201));
}
