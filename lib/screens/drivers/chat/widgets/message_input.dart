import 'package:flutter/material.dart';

class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onStartAudioRecording;
  final VoidCallback onStopAudioRecording;
  final VoidCallback onRecordVideo;
  final bool isRecordingAudio;
  final bool isSendingVideo;

  MessageInputField({
    required this.controller,
    required this.onSend,
    required this.onStartAudioRecording,
    required this.onStopAudioRecording,
    required this.onRecordVideo,
    required this.isRecordingAudio,
    required this.isSendingVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter message',
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          isSendingVideo
              ? CircularProgressIndicator() // Show loading indicator when video is being sent
              : IconButton(
                  icon: isRecordingAudio
                      ? Icon(Icons.stop, color: Colors.red)
                      : Icon(Icons.mic, color: Colors.blue),
                  onPressed: isRecordingAudio
                      ? onStopAudioRecording
                      : onStartAudioRecording,
                ),
          IconButton(
            icon: Icon(Icons.videocam, color: Colors.green),
            onPressed: onRecordVideo,
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
