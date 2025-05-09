import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AnnouncementsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _announcementController = TextEditingController();

  AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _announcementController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Post an Announcement',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) async {
              if (value.trim().isNotEmpty) {
                await _firestore.collection('announcements').add({
                  'message': value.trim(),
                  'timestamp': FieldValue.serverTimestamp(),
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Announcement posted')));
              }
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('announcements').orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              List<QueryDocumentSnapshot> announcements = snapshot.data!.docs;

              return ListView.builder(
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  var announcementData = announcements[index].data() as Map<String, dynamic>;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      title: Text(announcementData['message'] ?? 'No Message'),
                      subtitle: Text('Posted on: ${DateFormat('yyyy-MM-dd').format((announcementData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now())}'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}