import 'package:fixpal/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:fixpal/models/job_model.dart'; // Import JobModel
import 'package:fixpal/screens/job_details_screen.dart'; // Import JobDetailsScreen

class MyJobsScreen extends StatelessWidget {
  final String? userId; // User ID to filter jobs
  final bool isFreelancer; // Indicates if the user is a freelancer or client

  const MyJobsScreen({super.key, required this.userId, required this.isFreelancer});

  Stream<QuerySnapshot> _getJobsStream() {
    if (isFreelancer) {
      return FirebaseFirestore.instance.collection('applications').where('freelancerId', isEqualTo: userId).snapshots();
    } else {
      return FirebaseFirestore.instance.collection('jobs').where('postedBy', isEqualTo: userId).snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppConstants.white,
        title: Text(isFreelancer ? 'Jobs Applied' : 'Jobs Posted'),
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
        stream: _getJobsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading indicator
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Display error message
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    isFreelancer ? 'No jobs applied yet' : 'No jobs posted yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final List<QueryDocumentSnapshot> jobs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final jobData = jobs[index].data() as Map<String, dynamic>;
              final job = JobModel.fromMap(jobData); // Convert to JobModel

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: ListTile(
                  leading: const Icon(Icons.work, color: Colors.blue),
                  title: Text(job.title ?? 'No Title'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category: ${job.category ?? 'N/A'}'),
                      Text('Location: ${job.region ?? 'N/A'}, ${job.city ?? 'N/A'}'),
                      Text(
                        'Deadline: ${DateFormat('yyyy-MM-dd').format(job.deadline?.toDate() ?? DateTime.now())}',
                      ),
                      if (isFreelancer && jobData.containsKey('applicationStatus'))
                        Text('Status: ${jobData['applicationStatus'] ?? 'Not Applied'}'), // Show application status for freelancers
                      if (isFreelancer)
                        Text(
                          'Applied On: ${DateFormat('yyyy-MM-dd').format((jobData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now())}',
                        ), // Show application timestamp for freelancers
                      if (!isFreelancer)
                        Text(
                          'Posted On: ${DateFormat('yyyy-MM-dd').format((jobData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now())}',
                        ), // Show job posting timestamp for clients
                    ],
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailsScreen(
                            jobId: jobs[index].id,
                            jobData: jobData,
                            userId: userId ?? '', // Fallback to empty string if userId is null
                            isFreelancer: isFreelancer,
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                    child: const Text('View'), // Ensure 'child' is last
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

extension on DateTime? {
  toDate() {}
}