import 'package:coordimate/models/groups.dart';
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
  final GroupCard group;
  final DateTime dateTime;
  final MeetingStatus status;

  MeetingTileModel({
    this.id = '',
    required this.title,
    required this.dateTime,
    required this.group,
    this.status = MeetingStatus.needsAcceptance,
  });

  String getFormattedDate() {
    return DateFormat('EEE, MMMM d, HH:mm').format(dateTime);
  }

  bool isInPast() {
    return dateTime.isBefore(DateTime.now());
  }

  factory MeetingTileModel.fromJson(Map<String, dynamic> json) {
    return MeetingTileModel(
      id: json['id'].toString(),
      title: json['title'],
      group: GroupCard.fromJson(json['group']),
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
    required this.id,
    required this.username,
    required this.status,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['user_id'].toString(),
      username: json['user_username'],
      status: json['status'],
    );
  }
}

class MeetingDetails {
  final String id;
  final String title;
  final String groupId;
  final String groupName;
  final DateTime dateTime;
  final Participant admin;
  final String description;
  final List<Participant> participants;
  bool isFinished;
  MeetingStatus status;
  String summary;

  MeetingDetails({
    this.id = '',
    required this.title,
    required this.dateTime,
    required this.participants,
    required this.description,
    required this.admin,
    required this.groupId,
    required this.groupName,
    required this.status,
    required this.isFinished,
    required this.summary,
  });

  String getFormattedDate() {
    return DateFormat('EEEE, MMMM d').format(dateTime);
  }

  String getFormattedTime() {
    return DateFormat('HH:mm').format(dateTime);
  }

  bool isInPast() {
    return dateTime.isBefore(DateTime.now());
  }

  factory MeetingDetails.fromJson(Map<String, dynamic> json) {
    return MeetingDetails(
      id: json['id'].toString(),
      title: json['title'],
      groupId: json['group_id'].toString(),
      groupName: json['group_name'],
      dateTime: DateTime.parse(json['start']),
      admin: Participant.fromJson(json['admin']),
      description: json['description'] ?? '',
      status: json['status'] == 'accepted' ? MeetingStatus.accepted : json['status'] == 'declined' ? MeetingStatus.declined : MeetingStatus.needsAcceptance,
      participants: (json['participants'] as List).map((e) => Participant.fromJson(e)).toList(),
      isFinished: json['is_finished'] as bool,
      summary: json['summary'] ?? '',
    );
  }

}