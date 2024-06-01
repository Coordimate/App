class User {
  User({
    this.id = '',
    this.username = '',
    required this.email,
    this.password,
    this.authType,
  });

  final String id;
  String username;
  final String email;
  final String? password;
  final String? authType;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'],
      email: json['email'],
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    if (password == null) {
      return {
        'username': username,
        'email': email,
        'auth_type': authType,
      };
    } else {
      return {
        'username': username,
        'email': email,
        'password': password,
      };
    }
  }
}
