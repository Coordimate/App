class AgendaPoint {
  AgendaPoint({
    required this.text,
    required this.level,
  });

  String text = "";
  int level = 0;

  AgendaPoint.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    level = json['level'];
  }
}
