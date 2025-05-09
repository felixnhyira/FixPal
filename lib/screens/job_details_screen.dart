import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore database
import 'package:intl/intl.dart'; // For date formatting
import 'package:fixpal/screens/messages_screen.dart'; // Import MessagesScreen
import 'package:fixpal/models/job_model.dart'; // Import JobModel

class JobDetailsScreen extends StatelessWidget {
  final String jobId; // Unique job ID
  final Map<String, dynamic> jobData; // Job details
  final String userId; // Current user ID
  final bool isFreelancer; // Indicates if the user is a freelancer

  const JobDetailsScreen({
    super.key,
    required this.jobId,
    required this.jobData,
    required this.userId,
    required this.isFreelancer,
  });

  @override
  Widget build(BuildContext context) {
    final job = JobModel.fromMap(jobData); // Convert to JobModel

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Title
            Text(
              job.title ?? 'No Title',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Job Category
            Text('Category: ${job.category ?? 'N/A'}'),
            const SizedBox(height: 5),

            // Location
            Text('Location: ${job.region ?? 'N/A'}, ${job.city ?? 'N/A'}'),
            const SizedBox(height: 5),

            // Deadline (Formatted Date)
            Text(
              'Deadline: ${_formatDate(job.deadline)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 5),

            // Applicants Count
            Text(
              'Applicants: ${job.applicantsCount ?? 0}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Client Profile
            const Text(
              'Client Profile:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<DocumentSnapshot>(
              future: job.postedBy != null
                  ? FirebaseFirestore.instance.collection('users').doc(job.postedBy).get()
                  : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: CircularProgressIndicator()); // Show loading indicator
                }

                final clientData = snapshot.data!.data() as Map<String, dynamic>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${clientData['firstName']} ${clientData['lastName']}'),
                    Text('Email: ${clientData['email']}'),
                    Text('Phone: ${clientData['phoneNumber']}'),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Job Description
            const Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                job.description ?? 'No description provided.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            if (isFreelancer)
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Apply for the job
                    await FirebaseFirestore.instance.collection('applications').add({
                      'jobId': jobId,
                      'freelancerId': userId,
                      'status': 'pending',
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Application submitted successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error applying for job: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF062D8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text('Apply Now'), // Ensure 'child' is last
              )
            else
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MessagesScreen(
                        jobId: jobId,
                        otherUserId: job.postedBy,
                        userId: userId, // Use the passed userId
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF062D8A), // Blue color
                ),
                child: const Text('Chat with Client'), // Ensure 'child' is last
              ),
          ],
        ),
      ),
    );
  }

  // Helper Method to Format Deadline
  String _formatDate(dynamic deadline) {
    if (deadline == null) return 'N/A';
    if (deadline is Timestamp) {
      return DateFormat('yyyy-MM-dd').format(deadline.toDate());
    }
    if (deadline is DateTime) {
      return DateFormat('yyyy-MM-dd').format(deadline);
    }
    return deadline.toString();
  }
}