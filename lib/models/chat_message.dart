class ChatMessageModel {
  ChatMessageModel({
    required this.userId,
    required this.text,
  });

  String userId = "";
  String text = "";

  ChatMessageModel.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    userId = json['user_id'];
  }
}