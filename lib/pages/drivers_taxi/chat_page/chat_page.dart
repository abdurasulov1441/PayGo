import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class ChatPageTaxi extends StatefulWidget {
  const ChatPageTaxi({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPageTaxi> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool isTyping = false;
  bool isEmojiShowing = false;

  final List<Map<String, String>> _messages = [];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'sender': 'user',
      });
      _messageController.clear();
      isTyping = false;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _toggleEmojiPicker() {
    setState(() {
      isEmojiShowing = !isEmojiShowing;
      if (isEmojiShowing) {
        _focusNode.unfocus(); // Закрываем клавиатуру
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
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(
                          color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(),
          Offstage(
            offstage: !isEmojiShowing,
            child: EmojiPicker(
              textEditingController: _messageController,
              config: Config(
                height: 256,
                checkPlatformCompatibility: true,
                emojiViewConfig: EmojiViewConfig(
                  emojiSizeMax: 28 *
                      (foundation.defaultTargetPlatform == TargetPlatform.iOS
                          ? 1.2
                          : 1.0),
                ),
                skinToneConfig: const SkinToneConfig(),
                categoryViewConfig: const CategoryViewConfig(),
                bottomActionBarConfig: const BottomActionBarConfig(),
                searchViewConfig: const SearchViewConfig(),
              ),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 5, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          // Кнопка смайлика
          IconButton(
            onPressed: _toggleEmojiPicker,
            icon: SvgPicture.asset(
              'assets/icons/smile.svg',
              color: AppColors.uiText,
            ),
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
              onTap: () {
                setState(() {
                  isEmojiShowing = false;
                });
              },
              decoration: InputDecoration(
                hintStyle: AppStyle.fontStyle.copyWith(color: AppColors.uiText),
                hintText: "Habar",
                border: InputBorder.none,
              ),
            ),
          ),
          Row(
            children: [
              // Paperclip (Выбор файлов)
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/paperclip.svg',
                  color: AppColors.uiText,
                ),
                onPressed: () {
                  print("Выбор файла");
                },
              ),
              // Кнопка отправки / микрофон
              GestureDetector(
                onLongPress: () {
                  print("Долго нажал микрофон");
                },
                child: IconButton(
                  icon: SvgPicture.asset(
                    isTyping
                        ? 'assets/icons/send.svg'
                        : 'assets/icons/microphone.svg',
                    color: AppColors.uiText,
                  ),
                  onPressed: () {
                    if (isTyping) {
                      _sendMessage();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
