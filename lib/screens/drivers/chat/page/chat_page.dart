import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taksi/screens/drivers/chat/service/audio_service.dart';
import 'package:taksi/screens/drivers/chat/service/chat_service.dart';
import 'package:taksi/screens/drivers/chat/service/video_service.dart';
import 'package:taksi/screens/drivers/chat/widgets/message_bubble.dart';
import 'package:taksi/screens/drivers/chat/widgets/message_input.dart';

class ChatPage extends StatefulWidget {
  ChatPage();

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  ChatService _chatService = ChatService();
  AudioService _audioService = AudioService();
  VideoService _videoService = VideoService();

  String? _groupId;
  bool _isRecordingAudio = false;
  bool _isSendingVideo = false;

  @override
  void initState() {
    super.initState();

    _audioService.initializeRecorder();
  }

  Future<void> setupGroupChat(
      String fromRegion, String toRegion, String vehicleType) async {
    // Реализация логики создания группы, если ее нет
    try {
      QuerySnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('chatGroups')
          .where('from', whereIn: [fromRegion, toRegion])
          .where('to', whereIn: [toRegion, fromRegion])
          .where('type', isEqualTo: vehicleType)
          .get();

      if (groupSnapshot.docs.isEmpty) {
        DocumentReference newGroupRef =
            await FirebaseFirestore.instance.collection('chatGroups').add({
          'from': fromRegion,
          'to': toRegion,
          'type': vehicleType,
          'createdAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          _groupId = newGroupRef.id;
        });
      } else {
        setState(() {
          _groupId = groupSnapshot.docs.first.id;
        });
      }
    } catch (e) {
      print('Error setting up chat group: $e');
    }
  }

  void _sendTextMessage() {
    if (_messageController.text.isNotEmpty && _groupId != null) {
      FirebaseFirestore.instance
          .collection('chatGroups')
          .doc(_groupId)
          .collection('messages')
          .add({
        'text': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
      _messageController.clear();
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _startAudioRecording() async {
    setState(() {
      _isRecordingAudio = true;
    });
    await _audioService.startRecording();
  }

  Future<void> _stopAudioRecording() async {
    setState(() {
      _isRecordingAudio = false;
    });
    await _audioService.stopRecording();
    String? audioUrl = await _audioService.uploadAudio();
    if (audioUrl != null) {
      await _chatService.sendMessage(_groupId!, audioUrl, 'DriverName',
          FirebaseAuth.instance.currentUser!.uid);
    }
    _scrollToBottom();
  }

  Future<void> _recordVideo() async {
    final videoFile = await _videoService.recordVideo();
    if (videoFile != null) {
      setState(() {
        _isSendingVideo = true;
      });
      String? videoUrl = await _videoService.uploadVideo(videoFile);
      if (videoUrl != null) {
        await _chatService.sendMessage(_groupId!, videoUrl, 'DriverName',
            FirebaseAuth.instance.currentUser!.uid);
      }
      setState(() {
        _isSendingVideo = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: _groupId != null
                ? StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('chatGroups')
                        .doc(_groupId)
                        .collection('messages')
                        .orderBy('timestamp')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var message = snapshot.data!.docs[index];
                          final data = message.data() as Map<String, dynamic>;
                          return MessageBubble(data: data);
                        },
                      );
                    },
                  )
                : Center(child: CircularProgressIndicator()),
          ),
          MessageInputField(
            controller: _messageController,
            onSend: _sendTextMessage,
            onStartAudioRecording: _startAudioRecording,
            onStopAudioRecording: _stopAudioRecording,
            onRecordVideo: _recordVideo,
            isRecordingAudio: _isRecordingAudio,
            isSendingVideo: _isSendingVideo,
          ),
        ],
      ),
    );
  }
}
