import 'package:coordimate/keys.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

void getResponse(client, String url, String response, {int statusCode = 200}) {
  when(client.get(
    Uri.parse('$apiUrl$url'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response(response, statusCode));
}

void patchResponse(client, String url, String response,
    {int statusCode = 200}) {
  when(client.patch(
    Uri.parse('$apiUrl$url'),
    headers: anyNamed('headers'),
    body: anyNamed('body'),
  )).thenAnswer((_) async => http.Response(response, statusCode));
}

void patchBodyResponse(client, String url, Map<String, dynamic> body, String response,
    {int statusCode = 200}) {
  when(client.patch(
    Uri.parse('$apiUrl$url'),
    headers: anyNamed('headers'),
    body: body,
  )).thenAnswer((_) async => http.Response(response, statusCode));
}

void deleteResponse(client, String url, String response,
    {int statusCode = 204}) {
  when(client.delete(
    Uri.parse('$apiUrl$url'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response(response, statusCode));
}

void postBodyResponse(
    client, String url, Map<String, dynamic> body, String response,
    {int statusCode = 201}) {
  when(client.post(
    Uri.parse('$apiUrl$url'),
    headers: anyNamed('headers'),
    body: body,
  )).thenAnswer((_) async => http.Response(response, statusCode));
}

void postResponse(
    client, String url, String response,
    {int statusCode = 201}) {
  when(client.post(
    Uri.parse('$apiUrl$url'),
    headers: anyNamed('headers'),
    body: anyNamed('body'),
  )).thenAnswer((_) async => http.Response(response, statusCode));
}
