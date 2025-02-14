import 'dart:convert';

class ChatMessage {
  final String? text;
  final String time;
  late String status; // "sent" или "read"
  final String? photo;

  ChatMessage({
    required this.text,
    required this.time,
    required this.status,
    this.photo,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      time: json['time'],
      status: json['status'],
      photo: json['photo'],
    );
  }
}

// 📌 Генерируем сообщения (вместо базы)
List<ChatMessage> loadChatMessages() {
  String jsonData = '''
  [
    {"text": "Salom, qalesan?", "time": "10:30", "status": "read", "photo": null},
    {"text": "Bugun uchrashamizmi?", "time": "10:32", "status": "sent", "photo": null},
    {"text": null, "time": "10:35", "status": "read", "photo": "https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcShJaMbvFb7Y9rSOvH5_m9YCvBupQSlmWdp_N3Gx-gLmo2TCZiArXomLpnGWCVGYMWmfO_axWsJNs45ywYNpluSO5qx7jkDJBlD5iaVAhcyJnVc9G2L_cVn1NC0_NMR8KDrf0YvRA&usqp=CAc"}
  ]
  ''';

  List<dynamic> jsonList = jsonDecode(jsonData);
  return jsonList.map((e) => ChatMessage.fromJson(e)).toList();
}
