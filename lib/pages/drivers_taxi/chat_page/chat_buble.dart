import 'package:flutter/material.dart';
import 'chat_data.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;

  const ChatBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.text != null)
              Text(
                message.text!,
                style: TextStyle(color: isUser ? Colors.white : Colors.black),
              ),
            if (message.photo != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  message.photo!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUser ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(width: 5),
                if (isUser)
                  Icon(
                    message.status == "read" ? Icons.done_all : Icons.check,
                    size: 16,
                    color: message.status == "read"
                        ? Colors.white
                        : Colors.white70,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
