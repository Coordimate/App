class TimeSlot {
  TimeSlot({
    this.day = 0,
    this.start = 0.0,
    this.length = 0.0,
  });

  int day = 2;
  double start = 20.0;
  double length = 20.0;

  TimeSlot.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    start = json['start'];
    length = json['length'];
  }
}
