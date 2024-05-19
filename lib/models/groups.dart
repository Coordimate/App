class Group {
  final String id;
  final String name;
  final String description;

  Group({
    this.id = '',
    required this.name,
    this.description = '',
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'] ?? '',
    );
  }
}
