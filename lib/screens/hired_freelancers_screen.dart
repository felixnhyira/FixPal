import 'package:fixpal/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class HiredFreelancersScreen extends StatelessWidget {
  final String clientId;
  HiredFreelancersScreen({super.key, required this.clientId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('hiredFreelancers').where('clientId', isEqualTo: clientId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<QueryDocumentSnapshot> hiredFreelancers = snapshot.data!.docs;

        if (hiredFreelancers.isEmpty) {
          return const Center(child: Text('No freelancers hired yet.'));
        }

        return ListView.builder(
          itemCount: hiredFreelancers.length,
          itemBuilder: (context, index) {
            var hiredFreelancerData = hiredFreelancers[index].data() as Map<String, dynamic>;

            return HiredFreelancerCard(
              freelancerName: hiredFreelancerData['freelancerName'] ?? 'No Name',
              projectTitle: hiredFreelancerData['projectTitle'] ?? 'N/A',
              hiredOn: (hiredFreelancerData['hiredOn'] as Timestamp?)?.toDate() ?? DateTime.now(),
              profilePhotoUrl: hiredFreelancerData['freelancerProfilePhotoUrl'],
              jobId: hiredFreelancerData['jobId'] ?? '',
              otherUserId: hiredFreelancerData['freelancerId'] ?? '',
            );
          },
        );
      },
    );
  }
}

class HiredFreelancerCard extends StatelessWidget {
  final String freelancerName;
  final String projectTitle;
  final DateTime hiredOn;
  final String? profilePhotoUrl;
  final String jobId;
  final String otherUserId;

  const HiredFreelancerCard({
    super.key,
    required this.freelancerName,
    required this.projectTitle,
    required this.hiredOn,
    this.profilePhotoUrl,
    required this.jobId,
    required this.otherUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(profilePhotoUrl ?? 'https://via.placeholder.com/150'), // Placeholder image
        ),
        title: Text(freelancerName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project: $projectTitle'),
            Text('Hired On: ${DateFormat('yyyy-MM-dd').format(hiredOn)}'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  jobId: jobId,
                  otherUserId: otherUserId,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF062D8A),
            foregroundColor: Colors.white,
          ),
          child: const Text('Chat'),
        ),
      ),
    );
  }
}