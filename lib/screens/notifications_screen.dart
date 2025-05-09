import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF062D8A), // Primary blue color
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No new notifications'));
          }

          final List<QueryDocumentSnapshot> notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notificationData = notifications[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: ListTile(
                  title: Text(notificationData['title'] ?? 'No Title'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notificationData['message'] ?? 'No Message'),
                      Text(
                        DateFormat('yyyy-MM-dd hh:mm a').format(
                          (notificationData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                        ),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: notificationData['isRead'] == false
                      ? const CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.fiber_manual_record, size: 12, color: Colors.white),
                        )
                      : null,
                  onTap: () async {
                    // Mark notification as read
                    await FirebaseFirestore.instance.collection('notifications').doc(notifications[index].id).update({
                      'isRead': true,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(notificationData['title'] ?? 'No Title')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}