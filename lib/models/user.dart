import 'package:flutter/material.dart';

class User {
  User({
    this.id = '',
    this.username = '',
    required this.email,
    this.password,
    this.authType,
    this.randomCoffee,
  });

  final String id;
  String username;
  final String email;
  final String? password;
  final String? authType;
  final RandomCoffee? randomCoffee;

  factory User.fromJson(Map<String, dynamic> json) {
    final user = User(
        id: json['id'] ?? '',
        username: json['username'],
        email: json['email'],
        password: json['password'] ?? '',
        randomCoffee: RandomCoffee.fromJson(json['random_coffee']));
    return user;
  }

  Map<String, dynamic> toJson() {
    if (password == null) {
      return {
        'username': username,
        'email': email,
        'auth_type': authType,
        'random_coffee': randomCoffee?.toJson(),
      };
    } else {
      return {
        'username': username,
        'email': email,
        'password': password,
        'random_coffee': randomCoffee?.toJson(),
      };
    }
  }
}

class UserCard {
  UserCard({
    this.id = '',
    this.username = '',
  });

  final String id;
  String username;

  factory UserCard.fromJson(Map<String, dynamic> json) {
    return UserCard(
      id: json['id'] ?? '',
      username: json['username'],
    );
  }
}

class RandomCoffee {
  final bool isEnabled;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  RandomCoffee({
    required this.isEnabled,
    this.startTime,
    this.endTime,
  });

  factory RandomCoffee.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RandomCoffee(isEnabled: false);
    }

    final startTimePair =
        json['start_time'].toString().split(':').map((x) => int.parse(x));
    final endTimePair =
        json['end_time'].toString().split(':').map((x) => int.parse(x));

    return RandomCoffee(
      isEnabled: json['is_enabled'],
      startTime:
          TimeOfDay(hour: startTimePair.first, minute: startTimePair.last),
      endTime: TimeOfDay(hour: endTimePair.first, minute: endTimePair.last),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_enabled': isEnabled,
      'start_time': "${startTime!.hour}:${startTime!.minute}",
      'end_time': "${endTime!.hour}:${endTime!.minute}",
      'timezone': DateTime.now().timeZoneOffset.inMinutes.toString(),
    };
  }
}
