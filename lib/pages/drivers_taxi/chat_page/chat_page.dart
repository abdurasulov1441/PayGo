import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taksi/pages/drivers_taxi/chat_page/botom_sheet.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class ChatPageTaxi extends StatefulWidget {
  const ChatPageTaxi({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class ChatMessage {
  final String id, text, time, date, senderName;
  final bool isMe;

  ChatMessage(
      this.id, this.text, this.time, this.date, this.senderName, this.isMe);

  factory ChatMessage.fromJson(Map<String, dynamic> json, String date) {
    return ChatMessage(
      json['id'].toString(),
      json['message_text'] ?? '',
      json['created_at'],
      date,
      json['sender_name'],
      json['is_me'],
    );
  }
}

class _ChatPageState extends State<ChatPageTaxi> {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> messages = [];
  int? chatRoomId;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    chatRoomId = await _createOrJoinChat();
    if (chatRoomId != null) _loadMessages();
  }

  Future<int?> _createOrJoinChat() async {
    final chatId = await _post('/services/zyber/api/chat/create-chat', {}) ??
        await _post('/services/zyber/api/chat/join-chat', {});
    return chatId != null ? chatId['chat_room_id'] : null;
  }

  Future<void> _loadMessages() async {
    if (chatRoomId == null) return;
    final response = await _get(
        '/services/zyber/api/chat/get-messages?chat_room_id=$chatRoomId');
    if (response == null || response['success'] != true) return;

    List<ChatMessage> loadedMessages = [];
    for (var group in response['grouped_messages']) {
      String date = group['date'];
      for (var msg in group['messages']) {
        loadedMessages.add(ChatMessage.fromJson(msg, date));
      }
    }

    setState(() => messages = loadedMessages);
  }

  Future<void> _sendMessage() async {
    if (chatRoomId == null || _messageController.text.trim().isEmpty) return;
    await _post('/services/zyber/api/chat/send-message', {
      'chat_room_id': chatRoomId,
      'message_text': _messageController.text.trim()
    });

    _messageController.clear();
    _loadMessages();
  }

  Future<dynamic> _post(String url, Map<String, dynamic> data) async {
    try {
      final response = await requestHelper.postWithAuth(url, data);
      return response != null && response['success'] == true ? response : null;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> _get(String url) async {
    try {
      return await requestHelper.getWithAuth(url);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios, color: Colors.white),
        backgroundColor: AppColors.grade1,
        title: Text(
          "Чат",
          // "Чат с оператором"
          style: AppStyle.fontStyle.copyWith(color: Colors.white),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/back.jpg'), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                reverse: false,
                itemBuilder: (context, index) {
                  bool showDate = index == 0 ||
                      messages[index].date != messages[index - 1].date;
                  return Column(
                    children: [
                      if (showDate)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(messages[index].date,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      _buildChatBubble(messages[index]),
                    ],
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    bool isUser = message.isMe;
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser)
          CircleAvatar(
            backgroundColor: Colors.grey[400],
            child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : "?",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: isUser ? AppColors.grade1 : Colors.grey[300],
              borderRadius: isUser
                  ? BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    )
                  : BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
            ),
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isUser)
                  Text(message.senderName,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isUser ? Colors.white70 : Colors.black87)),
                if (message.text.isNotEmpty)
                  Text(message.text,
                      style: TextStyle(
                          fontSize: 16,
                          color: isUser ? Colors.white : Colors.black87)),
                Text(message.time,
                    style: TextStyle(
                        fontSize: 10,
                        color: isUser ? Colors.white70 : Colors.black54)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                  hintText: "Введите сообщение...", border: InputBorder.none),
            ),
          ),
          IconButton(
              icon: SvgPicture.asset('assets/icons/paperclip.svg'),
              onPressed: () => showAttachmentSheet(context)),
          IconButton(
              icon: SvgPicture.asset('assets/icons/send.svg'),
              onPressed: _sendMessage),
        ],
      ),
    );
  }
}
