import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:fixpal/screens/chat_screen.dart'; // Import ChatScreen

class MessagesScreen extends StatelessWidget {
  final String? userId; // User ID to filter messages

  const MessagesScreen({super.key, required this.userId, required String jobId, String? otherUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF062D8A), Color(0xFF8800FC)], // Blue-Purple gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getMessagesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<QueryDocumentSnapshot> messages = snapshot.data!.docs;

          if (messages.isEmpty) {
            return const Center(child: Text('No messages available'));
          }

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final messageData = messages[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(messageData['otherUserProfilePhotoUrl'] ?? ''),
                  ),
                  title: Text(messageData['otherUserFullName'] ?? 'Unknown User'),
                  subtitle: Text(
                    '${messageData['lastMessage'] ?? 'No messages yet'} - ${DateFormat('hh:mm a').format((messageData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now())}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            jobId: messageData['jobId'] ?? '',
                            otherUserId: messageData['otherUserId'] ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Fetch messages based on user ID
  Stream<QuerySnapshot> _getMessagesStream() {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('participants', arrayContains: userId) // Filter messages where the user is a participant
        .orderBy('timestamp', descending: true) // Order by newest first
        .snapshots();
  }
}