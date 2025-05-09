import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendMessage(String jobId, String otherUserId, String message) async {
    await _firestore.collection('messages').add({
      'jobId': jobId,
      'senderId': _auth.currentUser!.uid,
      'receiverId': otherUserId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessages(String jobId) {
    return _firestore
        .collection('messages')
        .where('jobId', isEqualTo: jobId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}