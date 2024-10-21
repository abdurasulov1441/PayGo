import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:io';
import 'package:path/path.dart' as path; // For handling file paths
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker(); // Image picker instance
  bool _isSendingImage = false;
  String? _groupId;

  @override
  void initState() {
    super.initState();
    _setupGroupChat();
  }

  Future<void> _setupGroupChat() async {
    // Similar logic as before for setting up or joining the group
    // You can include the _groupId setup here as in previous steps
  }

  void _sendTextMessage() async {
    if (_messageController.text.isNotEmpty && _groupId != null) {
      String message = _messageController.text;
      _messageController.clear();
      _scrollToBottom();

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        // Fetch driver data for sending the correct name
        DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
            .collection('driver')
            .doc(user.uid)
            .get();

        String driverName = driverSnapshot['name'];

        // Add text message to Firestore
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

  // Function to pick an image from gallery or capture from camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _isSendingImage = true; // Show loading indicator
        });
        File imageFile = File(pickedFile.path);
        await _uploadImage(imageFile); // Upload the image
      }
    } catch (e) {
      _showSnackBar("Error picking image: $e");
    } finally {
      setState(() {
        _isSendingImage = false; // Remove loading indicator
      });
    }
  }

  // Function to upload image to Firebase Storage
  Future<void> _uploadImage(File imageFile) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || _groupId == null) return;

      String fileName = path.basename(imageFile.path);
      UploadTask uploadTask = FirebaseStorage.instance
          .ref('chatImages/$fileName')
          .putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        String downloadURL = await snapshot.ref.getDownloadURL();

        // Add the image URL as a message in the chat
        await FirebaseFirestore.instance
            .collection('chatGroups')
            .doc(_groupId)
            .collection('messages')
            .add({
          'imageUrl': downloadURL,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user.uid,
          'userName': user.displayName ?? 'Unknown User',
        });

        _scrollToBottom();
      }
    } catch (e) {
      _showSnackBar("Error uploading image: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
                          final data = message.data() as Map<String, dynamic>?;

                          String userName = data?['userName'] ?? 'Unknown User';
                          String? textMessage = data?['text'];
                          String? imageUrl = data?['imageUrl'];
                          Timestamp? timestamp = data?['timestamp'];
                          String timeString = timestamp != null
                              ? DateFormat('HH:mm').format(timestamp.toDate())
                              : '';

                          bool isMe = FirebaseAuth.instance.currentUser!.uid ==
                              data?['userId'];

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Text(
                                        userName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    if (imageUrl != null)
                                      Image.network(imageUrl),
                                    if (textMessage != null) Text(textMessage),
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
          if (_isSendingImage)
            CircularProgressIndicator(), // Show loading when sending image
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: () =>
                      _pickImage(ImageSource.gallery), // Pick from gallery
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () =>
                      _pickImage(ImageSource.camera), // Capture from camera
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
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
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendTextMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
