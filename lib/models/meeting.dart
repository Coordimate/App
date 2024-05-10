import 'package:intl/intl.dart';

enum MeetingStatus {
  declined,
  accepted,
  needsAcceptance,
}
// TODO: technically it's not used
class Meeting {

  final String id;
  final String title;
  final String group;
  final DateTime dateTime;
  final String adminId;
  final String description;

  Meeting({
    this.id = '',
    required this.title,
    required this.dateTime,
    this.description = '',
    this.adminId = '',
    this.group = '',
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
      // status: json['status'] == 'accepted' ? MeetingStatus.accepted : json['status'] == 'declined' ? MeetingStatus.declined : MeetingStatus.needsAcceptance,
    );
  }
}

class MeetingTileModel {
  final String id;
  final String title;
  final String group;
  final DateTime dateTime;
  final MeetingStatus status;

  MeetingTileModel({
    this.id = '',
    required this.title,
    required this.dateTime,
    this.group = '',
    this.status = MeetingStatus.needsAcceptance,
  });

  String getFormattedDate() {
    return DateFormat('EEE, MMMM d, HH:mm').format(dateTime);
  }

  factory MeetingTileModel.fromJson(Map<String, dynamic> json) {
    return MeetingTileModel(
      id: json['id'].toString(),
      title: json['title'],
      group: json['group_id'].toString(),
      dateTime: DateTime.parse(json['start']),
      status: json['status'] == 'accepted' ? MeetingStatus.accepted : json['status'] == 'declined' ? MeetingStatus.declined : MeetingStatus.needsAcceptance,
    );
  }
}

class Participant {
  final String id;
  final String username;
  final String status;

  Participant({
    this.id = '',
    required this.username,
    required this.status,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'].toString(),
      username: json['username'],
      status: json['status'],
    );
  }
}

class MeetingDetails {
  final String id;
  final String title;
  final String group;
  final DateTime dateTime;
  final String adminId;
  final String description;
  final List<Participant> participants;
  final MeetingStatus status;

  MeetingDetails({
    this.id = '',
    required this.title,
    required this.dateTime,
    required this.participants,
    required this.description,
    required this.adminId,
    required this.group,
    required this.status,
  });

  String getFormattedDate() {
    return DateFormat('EEE, MMMM d, HH:mm').format(dateTime);
  }

  factory MeetingDetails.fromJson(Map<String, dynamic> json) {
    return MeetingDetails(
      id: json['id'].toString(),
      title: json['title'],
      group: json['group_id'].toString(),
      dateTime: DateTime.parse(json['start']),
      adminId: json['admin_id'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] == 'accepted' ? MeetingStatus.accepted : json['status'] == 'declined' ? MeetingStatus.declined : MeetingStatus.needsAcceptance,
      participants: (json['participants'] as List).map((e) => Participant.fromJson(e)).toList(),
    );
  }

}