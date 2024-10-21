import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> setupGroupChat(
      String fromRegion, String toRegion, String vehicleType) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String chatGroupType =
            vehicleType == 'taksi' ? 'taksiGroup' : 'truckGroup';

        // Check if a chat group exists for the combination of regions and vehicle type
        QuerySnapshot groupSnapshot = await _firestore
            .collection('chatGroups')
            .where('from', whereIn: [fromRegion, toRegion])
            .where('to', whereIn: [toRegion, fromRegion])
            .where('type', isEqualTo: chatGroupType)
            .get();

        if (groupSnapshot.docs.isEmpty) {
          // Create a new group if none exists
          DocumentReference newGroupRef =
              await _firestore.collection('chatGroups').add({
            'from': fromRegion,
            'to': toRegion,
            'type': chatGroupType,
            'createdAt': FieldValue.serverTimestamp(),
          });
          return newGroupRef.id;
        } else {
          return groupSnapshot.docs.first.id;
        }
      }
    } catch (e) {
      print('Error setting up group chat: $e');
      return null;
    }
    return null;
  }

  Future<void> sendMessage(
      String groupId, String message, String userName, String userId) async {
    try {
      await _firestore
          .collection('chatGroups')
          .doc(groupId)
          .collection('messages')
          .add({
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
        'userName': userName,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}
