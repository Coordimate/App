import 'package:coordimate/models/groups.dart';
import 'package:intl/intl.dart';

enum MeetingStatus {
  declined,
  accepted,
  needsAcceptance,
}

class MeetingTileModel {
  final String id;
  final String title;
  final GroupCard group;
  final DateTime dateTime;
  final int duration;
  final MeetingStatus status;
  final bool isFinished;

  MeetingTileModel({
    this.id = '',
    required this.title,
    required this.dateTime,
    required this.duration,
    required this.group,
    this.status = MeetingStatus.needsAcceptance,
    required this.isFinished,
  });

  String getFormattedDate() {
    return DateFormat('EEE, MMMM d, HH:mm').format(dateTime);
  }

  bool isInPast() {
    return getFinishTime().isBefore(DateTime.now());
  }

  DateTime getFinishTime() {
    return dateTime.add(Duration(minutes: duration));
  }

  factory MeetingTileModel.fromJson(Map<String, dynamic> json) {
    return MeetingTileModel(
        id: json['id'].toString(),
        title: json['title'],
        group: GroupCard.fromJson(json['group']),
        dateTime: DateTime.parse(json['start']),
        duration: json['length'],
        status: json['status'] == 'accepted'
            ? MeetingStatus.accepted
            : json['status'] == 'declined'
                ? MeetingStatus.declined
                : MeetingStatus.needsAcceptance,
        isFinished: json['is_finished'] as bool);
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
  final int duration;
  final Participant admin;
  final String description;
  final String? meetingLink;
  final List<Participant> participants;
  bool isFinished;
  MeetingStatus status;
  String summary;

  MeetingDetails({
    this.id = '',
    required this.title,
    required this.dateTime,
    required this.duration,
    required this.participants,
    required this.description,
    required this.admin,
    required this.groupId,
    required this.groupName,
    required this.status,
    required this.isFinished,
    required this.summary,
    this.meetingLink,
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
      duration: json['length'],
      admin: Participant.fromJson(json['admin']),
      description: json['description'] ?? '',
      status: json['status'] == 'accepted'
          ? MeetingStatus.accepted
          : json['status'] == 'declined'
              ? MeetingStatus.declined
              : MeetingStatus.needsAcceptance,
      participants: (json['participants'] as List)
          .map((e) => Participant.fromJson(e))
          .toList(),
      isFinished: json['is_finished'] as bool,
      meetingLink:
          json.containsKey('meeting_link') ? json['meeting_link'] : null,
      summary: json['summary'] ?? '',
    );
  }
}

