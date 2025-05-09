import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore database
import 'package:firebase_auth/firebase_auth.dart'; // For user authentication

class ChatScreen extends StatefulWidget {
  final String jobId; // Unique identifier for the job
  final String otherUserId; // ID of the other user (client or freelancer)

  const ChatScreen({
    super.key,
    required this.jobId,
    required this.otherUserId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _messageController = TextEditingController();

  // Function to send a message
  void sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    try {
      // Save the message to Firestore
      await _firestore.collection('messages').add({
        'jobId': widget.jobId,
        'senderId': _auth.currentUser!.uid,
        'receiverId': widget.otherUserId,
        'message': message.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the input field
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        backgroundColor: Color(0xFF062D8A), // Primary blue color
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .where('jobId', isEqualTo: widget.jobId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<QueryDocumentSnapshot> messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index].data() as Map<String, dynamic>;
                    bool isCurrentUser = messageData['senderId'] == _auth.currentUser?.uid;

                    return Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          messageData['message'],
                          style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Capture context before async operation
                    FocusScope.of(context).unfocus(); // Hide keyboard before sending
                    sendMessage(_messageController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF062D8A), // Use 'backgroundColor' instead of 'primary'
                    foregroundColor: Colors.white, // Use 'foregroundColor' instead of 'onPrimary'
                  ),
                  child: Text('Send'), // Ensure 'child' is last
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}