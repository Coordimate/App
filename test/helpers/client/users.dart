import 'package:coordimate/keys.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

const userCard = '{"id": "userid", "username": "user", "auth_type": "google"}';

void whenUserDetails(client) {
  when(client.get(
    Uri.parse('$apiUrl/users/userid'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response(userCard, 200));
}

