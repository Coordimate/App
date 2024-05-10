class TimeSlot {
  TimeSlot({
    required this.id,
    this.day = 0,
    this.start = 0.0,
    this.length = 0.0,
  });

  int id = -1;
  int day = 2;
  double start = 20.0;
  double length = 20.0;

  TimeSlot.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    day = json['day'];
    start = json['start'];
    length = json['length'];
  }
}
