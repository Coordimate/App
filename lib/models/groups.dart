class Group {
  final String id;
  String name;
  String description;
  String adminId;
  GroupPoll? poll;
  String groupMeetingLink;

  Group({
    this.id = '',
    required this.name,
    this.adminId = '',
    this.description = '',
    this.poll,
    this.groupMeetingLink = '',
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    try {
      var group = Group(
        id: json['id'].toString(),
        name: json['name'],
        adminId: json['admin']['_id'] ?? json['admin']['id'],
        description: json['description'] ?? '',
        groupMeetingLink: json['meeting_link'] ?? '',
      );
      if (json['poll'] != null) {
        group.poll = GroupPoll.fromJson(json['poll']);
      }
      return group;
    } catch(e) {
      throw Exception("can't parse group: $json, exception: $e");
    }

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

class GroupPoll {
  final String question;
  final List<String> options;
  Map<int, List<String>>? votes;

  GroupPoll({
    required this.question,
    required this.options,
    this.votes,
  });

  factory GroupPoll.fromJson(Map<String, dynamic> json) {
    Map<int, List<String>> parseVotes(Map<String, dynamic> json) {
      Map<int, List<String>> votes = {};
      json.forEach((key, value) {
        votes[int.parse(key)] = List.castFrom<dynamic, String>(value);
      });
      return votes;
    }

    var groupPoll = GroupPoll(
      question: json['question'].toString(),
      options: List.castFrom<dynamic, String>(json['options']),
    );
    if (json['votes'] != null) {
      groupPoll.votes = parseVotes(json['votes']);
    }
    return groupPoll;
  }
}
