import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ChatProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send a message
  Future<void> sendMessage(String jobId, String message) async {
    try {
      await _firestore.collection('messages').add({
        'jobId': jobId,
        'senderId': _auth.currentUser!.uid,
        'receiverId': 'otherUserId', // Replace with actual receiver ID
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
       if (kDebugMode){
        debugPrint('Error sending message: $e');
      rethrow;
       }
    }
  }

  // Fetch messages for a specific job
  Stream<QuerySnapshot> fetchMessagesForJob(String jobId) {
    return _firestore
        .collection('messages')
        .where('jobId', isEqualTo: jobId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}