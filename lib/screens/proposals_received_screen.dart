// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProposalsReceivedScreen extends StatelessWidget {
  final String clientId;
  ProposalsReceivedScreen({super.key, required this.clientId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('applications').where('clientId', isEqualTo: clientId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<QueryDocumentSnapshot> applications = snapshot.data!.docs;

        if (applications.isEmpty) {
          return const Center(child: Text('No proposals received yet.'));
        }

        return ListView.builder(
          itemCount: applications.length,
          itemBuilder: (context, index) {
            var applicationData = applications[index].data() as Map<String, dynamic>;

            return ApplicationCard(
              freelancerName: applicationData['freelancerName'] ?? 'No Name',
              jobTitle: applicationData['jobTitle'] ?? 'N/A',
              status: applicationData['status'] ?? 'Pending',
              profilePhotoUrl: applicationData['freelancerProfilePhotoUrl'],
              applicationId: applications[index].id,
              firestore: _firestore,
            );
          },
        );
      },
    );
  }
}

class ApplicationCard extends StatelessWidget {
  final String freelancerName;
  final String jobTitle;
  final String status;
  final String? profilePhotoUrl;
  final String applicationId;
  final FirebaseFirestore firestore;

  const ApplicationCard({
    super.key,
    required this.freelancerName,
    required this.jobTitle,
    required this.status,
    this.profilePhotoUrl,
    required this.applicationId,
    required this.firestore,
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
            Text('Job Title: $jobTitle'),
            Text('Status: $status'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  await firestore.collection('applications').doc(applicationId).update({'status': 'hired'});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Freelancer hired')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error hiring freelancer: $e')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF062D8A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Hire'),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () async {
                try {
                  await firestore.collection('applications').doc(applicationId).update({'status': 'rejected'});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Freelancer rejected')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error rejecting freelancer: $e')));
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Reject'),
            ),
          ],
        ),
      ),
    );
  }
}