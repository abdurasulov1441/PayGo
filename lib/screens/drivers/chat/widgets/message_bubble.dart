import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> data;

  MessageBubble({required this.data});

  @override
  Widget build(BuildContext context) {
    final String? textMessage = data['text'];
    final String? voiceMessage = data['voiceMessage'];
    final String? videoMessage = data['videoMessage'];
    final String userName = data['userName'] ?? 'Unknown User';

    return Align(
      alignment: Alignment.centerLeft,
      child: Card(
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName, style: TextStyle(fontWeight: FontWeight.bold)),
              if (textMessage != null) Text(textMessage),
              if (voiceMessage != null)
                Icon(Icons.audiotrack), // You can use a sound player here
              if (videoMessage != null)
                Icon(Icons.videocam), // You can use a video player here
            ],
          ),
        ),
      ),
    );
  }
}
