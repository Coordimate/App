class TimeSlot {
  TimeSlot({
    required this.id,
    this.day = 0,
    this.start = 0.0,
    this.length = 0.0,
    this.isMeeting = false,
  });

  String id = "";
  int day = 2;
  double start = 20.0;
  double length = 20.0;
  bool isMeeting = false;

  TimeSlot.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    day = json['day'];
    start = DateTime.parse(json['start']).toLocal().hour +
        DateTime.parse(json['start']).toLocal().minute / 60;
    length = json['length'] / 60;
    isMeeting = json['is_meeting'];
  }
}
