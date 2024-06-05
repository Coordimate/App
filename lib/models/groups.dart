class Group {
  final String id;
  String name;
  String description;

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

class GroupCard {
  final String id;
  final String name;

  GroupCard({
    this.id = '',
    required this.name,
  });

  factory GroupCard.fromJson(Map<String, dynamic> json) {
    return GroupCard(
      id: json['id'].toString(),
      name: json['name'],
    );
  }
}
