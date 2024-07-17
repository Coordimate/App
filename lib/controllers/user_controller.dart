import 'package:coordimate/app_state.dart';
import 'package:coordimate/keys.dart';
import 'dart:convert';
import 'package:coordimate/models/user.dart';

class UserController {
  Future<User> getInfo() async {
    final id = await AppState.authController.getAccountId();
    var url = Uri.parse("$apiUrl/users/$id");
    final response = await AppState.authController.client.get(
        url,
        headers: {"Content-Type": "application/json"}
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }
    return  User.fromJson(json.decode(response.body));
  }

  Future<void> changeUsername(username, id) async {
    var url = Uri.parse("$apiUrl/users/$id");
    final response = await AppState.authController.client.patch(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(<String, dynamic>{
          'username': username,
        }));
    if (response.statusCode != 200) {
      throw Exception('Failed to save data');
    }
  }

  Future<void> deleteUser(id) async {
    var url = Uri.parse("$apiUrl/users/$id");
    final response =
    await AppState.authController.client.delete(
        url,
        headers: {"Content-Type": "application/json"}
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  Future<bool> sendChangePswdRequest(newPswd, oldPswd) async {
    var url = Uri.parse("$apiUrl/change_password");
    final response = await AppState.authController.client.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(<String, dynamic>{
          'new_password': newPswd,
          'old_password': oldPswd,
        }));
    if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 403) {
      return false;
    } else {
      throw Exception('Failed to save data');
    }
  }
}