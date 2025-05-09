import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProposalsScreen extends StatelessWidget {
  final String? userId;

  const ProposalsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('freelancerId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final applications = snapshot.data!.docs;

        if (applications.isEmpty) {
          return const Center(child: Text('No proposals sent yet'));
        }

        return ListView.builder(
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final applicationData = applications[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: ListTile(
                title: Text(applicationData['jobTitle'] ?? 'No Title'),
                subtitle: Text('Status: ${applicationData['status'] ?? 'Pending'}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Proposal details')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF062D8A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}