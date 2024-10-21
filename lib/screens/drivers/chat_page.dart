import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';
import 'package:taksi/screens/drivers/voice_managment.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;
  String? _filePath;
  Stopwatch _stopwatch = Stopwatch();
  String? _groupId;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _setupGroupChat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        _scrollToBottom();
      }
    });
  }

  void _sendTextMessage() async {
    if (_messageController.text.isNotEmpty && _groupId != null) {
      String message = _messageController.text;
      _messageController.clear();
      _scrollToBottom();

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
            .collection('driver')
            .doc(user.uid)
            .get();

        String driverName = driverSnapshot['name'];

        await FirebaseFirestore.instance
            .collection('chatGroups')
            .doc(_groupId)
            .collection('messages')
            .add({
          'text': message,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user.uid,
          'userName': driverName,
        });
      } catch (e) {
        _showSnackBar("Error sending message: $e");
      }
    }
  }

  Future<void> _setupGroupChat() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch driver data from Firestore
        DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
            .collection('driver')
            .doc(user.uid)
            .get();

        if (driverSnapshot.exists) {
          String fromRegion = driverSnapshot['from'];
          String toRegion = driverSnapshot['to'];
          String vehicleType = driverSnapshot['vehicleType'];

          // Use the vehicle type for group chat separation
          String chatGroupType =
              (vehicleType == 'Mashina') ? 'taksiGroup' : 'truckGroup';

          // Check if a chat group exists for this combination of regions and vehicle type
          QuerySnapshot groupSnapshot = await FirebaseFirestore.instance
              .collection('chatGroups')
              .where('from', whereIn: [fromRegion, toRegion])
              .where('to', whereIn: [toRegion, fromRegion])
              .where('type',
                  isEqualTo:
                      chatGroupType) // Group based on vehicle type (mashina/gruzovik)
              .get();

          if (groupSnapshot.docs.isEmpty) {
            // If no group exists, create a new one for the vehicle type
            DocumentReference newGroupRef =
                await FirebaseFirestore.instance.collection('chatGroups').add({
              'from': fromRegion,
              'to': toRegion,
              'type': chatGroupType, // Store the vehicle type in the group
              'createdAt': FieldValue.serverTimestamp(),
            });
            setState(() {
              _groupId = newGroupRef.id; // Store the groupId
            });
          } else {
            // If the group exists, join the group
            setState(() {
              _groupId = groupSnapshot.docs.first.id;
            });
          }
        }
      }
    } catch (e) {
      _showSnackBar("Error setting up chat group: $e");
    }
  }

  void _initializeRecorder() async {
    try {
      await _recorder.openRecorder();
      if (await Permission.microphone.request().isGranted) {
        setState(() {});
      }
    } catch (e) {
      _showSnackBar("Failed to initialize recorder: $e");
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _scrollController.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  void _startRecording() async {
    if (!_recorder.isRecording) {
      try {
        await _recorder.openRecorder();
      } catch (e) {
        _showSnackBar('Failed to open recorder: $e');
        return;
      }
    }

    try {
      Directory tempDir = await getTemporaryDirectory();
      _filePath = '${tempDir.path}/voice_message.aac';

      _stopwatch.start();

      await _recorder.startRecorder(
        toFile: _filePath,
        codec: Codec.aacADTS,
      );

      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      _showSnackBar('Failed to start recording: $e');
    }
  }

  void _stopRecording() async {
    await _recorder.stopRecorder();
    _stopwatch.stop();

    int duration = _stopwatch.elapsed.inSeconds;
    _stopwatch.reset();

    setState(() {
      _isRecording = false;
    });

    _scrollToBottom();
    _uploadVoiceMessage(duration);
  }

  void _uploadVoiceMessage(int duration) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || _groupId == null) return;

      final file = File(_filePath!);
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.aac';
      UploadTask uploadTask =
          FirebaseStorage.instance.ref('voiceMessages/$fileName').putFile(file);

      TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        String downloadURL = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('chatGroups')
            .doc(_groupId)
            .collection('messages')
            .add({
          'voiceMessage': downloadURL,
          'duration': duration,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user.uid,
          'userName': user.displayName ?? 'Unknown User',
        });
      }
    } catch (e) {
      _showSnackBar("Error uploading voice message: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Allow the layout to move with the keyboard
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: AppColors.taxi,
        title: Text(
          'Chat',
          style: AppStyle.fontStyle.copyWith(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Static Background Image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/back_chat.png'),
                  fit: BoxFit.none,
                ),
              ),
            ),
          ),
          // Chat Content
          Column(
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
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                          });

                          return ListView.builder(
                            controller: _scrollController,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var message = snapshot.data!.docs[index];
                              final data =
                                  message.data() as Map<String, dynamic>?;

                              String userName =
                                  data?['userName'] ?? 'Unknown User';
                              String? textMessage = data?['text'];
                              String? voiceMessage = data?['voiceMessage'];
                              int? duration = data?['duration'];
                              Timestamp? timestamp = data?['timestamp'];
                              String timeString = timestamp != null
                                  ? DateFormat('HH:mm')
                                      .format(timestamp.toDate())
                                  : '';

                              bool isMe =
                                  FirebaseAuth.instance.currentUser!.uid ==
                                      data?['userId'];

                              return Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Card(
                                  color: isMe ? Colors.green[50] : Colors.white,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: isMe
                                          ? Radius.circular(10)
                                          : Radius.circular(0),
                                      bottomRight: isMe
                                          ? Radius.circular(0)
                                          : Radius.circular(10),
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (!isMe)
                                          Text(
                                            userName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        if (voiceMessage != null)
                                          VoiceMessageWidget(
                                            path: voiceMessage,
                                            duration: duration ?? 0,
                                            timeString: timeString,
                                          )
                                        else
                                          Text(textMessage ?? ''),
                                        Text(
                                          timeString,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    : Center(child: CircularProgressIndicator()),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Yozish...',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onTap: _scrollToBottom, // Scroll when tapping on input
                      ),
                    ),
                    IconButton(
                      icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                      onPressed:
                          _isRecording ? _stopRecording : _startRecording,
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _sendTextMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
