import 'package:intl/intl.dart';

enum MeetingStatus {
  declined,
  accepted,
  needsAcceptance,
}

class Meeting {

  final String id;
  final String title;
  final String group;
  final DateTime dateTime;
  final String adminId;
  final String description;
  // for meeting tiles
  final MeetingStatus status;

  Meeting({
    this.id = '',
    required this.title,
    required this.dateTime,
    this.description = '',
    this.adminId = '',
    this.group = '',
    this.status = MeetingStatus.needsAcceptance,
  });

  String getFormattedDate() {
    return DateFormat('EEE, MMMM d, HH:mm').format(dateTime);
  }

  factory Meeting.fromJson(Map<String, dynamic> json) {
    print("json data ${json['start']}");
    print(DateTime.parse(json['start']));
    return Meeting(
      id: json['id'].toString(),
      title: json['title'],
      group: json['group_id'].toString(),
      dateTime: DateTime.parse(json['start']),
      adminId: json['admin_id'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] == 'accepted' ? MeetingStatus.accepted : json['status'] == 'declined' ? MeetingStatus.declined : MeetingStatus.needsAcceptance,
    );
  }
}