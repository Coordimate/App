import 'package:intl/intl.dart';

class Meeting {
  Meeting({
    this.id = '',
    required this.title,
    required this.dateTime,
    this.description = '',
    this.adminId = '',
    this.groupId = '',
    required this.needsAcceptance,
    required this.isAccepted
  });

  final String id;
  final String title;
  final String groupId;
  final DateTime dateTime;
  final String adminId;
  final String description;
  final bool needsAcceptance;
  final bool isAccepted;

  String getFormattedDate() {
    return DateFormat('EEE, MMMM d, HH:mm').format(dateTime);
  }

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
      needsAcceptance: json['needs_acceptance'],
      isAccepted: json['is_accepted']
    );
  }
}