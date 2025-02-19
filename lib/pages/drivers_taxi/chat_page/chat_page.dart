import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:taksi/pages/drivers_taxi/chat_page/bubble.dart';
import 'package:taksi/pages/drivers_taxi/chat_page/provider/chat_provider.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;

  const ChatScreen({
    Key? key,
    required this.chatRoomId,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<ChatProvider>(context, listen: false)
        .fetchMessages(widget.chatRoomId);
  }

  @override
  Widget build(BuildContext context) {
    String? userId = cache.getString("user_id");
    var chatProvider = Provider.of<ChatProvider>(context);
    if (chatProvider.editingMessageText != null) {
      _messageController.text = chatProvider.editingMessageText!;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.grade1,
        title: Text(
          "Chat",
          style: AppStyle.fontStyle.copyWith(color: AppColors.ui, fontSize: 20),
        ),
        leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.ui,
            )),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/back.jpg",
              fit: BoxFit.cover,
            ),
          ),
          LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
                reverse: true,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      Expanded(
                        child: Consumer<ChatProvider>(
                          builder: (context, chatProvider, child) {
                            if (chatProvider.groupedMessages.isEmpty) {
                              return Center(
                                  child: Text("Загрузка сообщений..."));
                            }

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToBottom();
                            });

                            return ListView.builder(
                              reverse: false,
                              controller: _scrollController,
                              itemCount: chatProvider.groupedMessages.length,
                              itemBuilder: (context, index) {
                                final group =
                                    chatProvider.groupedMessages[index];

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Text(
                                          group["date"],
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    ...group["messages"].map<Widget>((message) {
                                      bool isMe =
                                          message["sender_id"] == userId;

                                      return MyChatBubble(
                                        id: message["id"],
                                        text: message["message_text"],
                                        isSender: isMe,
                                        time: message["created_at"],
                                        senderName: message["sender_name"],
                                      );
                                    }).toList(),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        color: AppColors.backgroundColor,
                        width: double.infinity,
                        height: 55,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.backgroundColor,
                                  hintText: "Введите сообщение...",
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.backgroundColor),
                                      borderRadius: BorderRadius.circular(10)),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.backgroundColor),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.backgroundColor),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: SvgPicture.asset("assets/icons/send.svg",
                                  color: AppColors.grade1),
                              onPressed: () async {
                                if (_messageController.text.isNotEmpty) {
                                  if (chatProvider.editingMessageId != null) {
                                    /// **Agar xabar tahrirlanayotgan bo‘lsa**
                                    await chatProvider.editMessageGroup(
                                        chatProvider.editingMessageId!,
                                        _messageController.text);
                                  } else {
                                    /// **Yangi xabar yuborish**
                                    await chatProvider.sendMessage(
                                        widget.chatRoomId,
                                        _messageController.text);
                                  }
                                  _messageController.clear();
                                  _scrollToBottom();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ));
          }),
        ],
      ),

      resizeToAvoidBottomInset: true, // Добавьте эту строку
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    }
  }
}
