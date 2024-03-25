class User {
  User({
    this.id = 0,
    this.username = '',
    required this.email,
    required this.password
  });

  final int id;
  final String username;
  final String email;
  final String password;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }
}