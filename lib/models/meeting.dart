class Meeting {
  Meeting({
    this.id = '',
    required this.title,
    required this.dateTime,
    this.description = '',
    this.adminId = '',
    this.groupId = '',
  });

  final String id;
  final String title;
  final String groupId;
  final DateTime dateTime;
  final String adminId;
  final String description;

  factory Meeting.fromJson(Map<String, dynamic> json) {
    print("json data ${json['start']}");
    print(DateTime.parse(json['start']));
    return Meeting(
      id: json['id'] ?? 0,
      title: json['title'],
      groupId: json['group_id'],
      dateTime: DateTime.parse(json['start']),
      adminId: json['admin_id'],
      description: json['description'],
    );
  }
}