import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/pages/drivers_taxi/chat_page/chat_buble.dart';
import 'package:taksi/pages/drivers_taxi/chat_page/chat_data.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class ChatPageTaxi extends StatefulWidget {
  const ChatPageTaxi({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPageTaxi> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isTyping = false;
  bool isEmojiShowing = false;
  final List<ChatMessage> _messages = loadChatMessages();

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text.trim(),
        time: "11:00",
        status: "sent",
      ));
      _messageController.clear();
      isTyping = false;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.last.status = "read";
      });
    });
  }

  void _toggleEmojiPicker() {
    setState(() {
      isEmojiShowing = !isEmojiShowing;
      if (isEmojiShowing) {
        _focusNode.unfocus();
      } else {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.backgroundColor),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text("Chat",
            style:
                AppStyle.fontStyle.copyWith(fontSize: 20, color: Colors.white)),
        backgroundColor: AppColors.grade1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.status == "sent";
                return ChatBubble(message: message, isUser: isUser);
              },
            ),
          ),
          _buildMessageInput(),
          Offstage(
            offstage: !isEmojiShowing,
            child: EmojiPicker(
              textEditingController: _messageController,
              onEmojiSelected: (category, emoji) {
                setState(() {
                  isTyping = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2)),
      ]),
      child: Row(
        children: [
          IconButton(
            onPressed: _toggleEmojiPicker,
            icon: SvgPicture.asset('assets/icons/smile.svg',
                color: AppColors.uiText),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              onChanged: (text) {
                setState(() {
                  isTyping = text.isNotEmpty;
                });
              },
              decoration:
                  InputDecoration(hintText: "Habar", border: InputBorder.none),
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(
              isTyping
                  ? 'assets/icons/send.svg'
                  : 'assets/icons/microphone.svg',
              color: AppColors.uiText,
            ),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
