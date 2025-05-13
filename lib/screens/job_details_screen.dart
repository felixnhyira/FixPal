import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixpal/screens/messages_screen.dart';
import 'package:fixpal/models/job_model.dart';
import '../utils/date_formatter.dart';
import '../widgets/countdown_timer.dart'; // Make sure this path is correct

class JobDetailsScreen extends StatelessWidget {
  final String jobId;
  final Map<String, dynamic> jobData;
  final String userId;
  final bool isFreelancer;

  const JobDetailsScreen({
    super.key,
    required this.jobId,
    required this.jobData,
    required this.userId,
    required this.isFreelancer,
  });

  @override
  Widget build(BuildContext context) {
    final job = JobModel.fromMap(jobData);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: Navigator.of(context).pop,
        ),
        title: const Text(
          'Job Details',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF062D8A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Title & Info Card
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title ?? 'No Title',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.category_outlined, color: Colors.blue.shade900),
                        const SizedBox(width: 5),
                        Text('Category: ${job.category ?? 'N/A'}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text('${job.region ?? 'N/A'}, ${job.city ?? 'N/A'}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Deadline + Badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text('Deadline: ${DateFormatter.formatDate(job.deadline)}'),
                            const SizedBox(width: 8),
                            Tooltip(
                              message:
                              DateFormatter.formatRelativeTime(job.deadline),
                              child: const Icon(Icons.info_outline,
                                  size: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: DateFormatter.getDeadlineColor(job.deadline)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: DateFormatter.getDeadlineColor(job.deadline)
                                  .withOpacity(0.6),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: DateFormatter.getDeadlineColor(job.deadline),
                              ),
                              const SizedBox(width: 6),
                              CountdownTimer(deadline: job.deadline),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.people_alt_outlined, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text('Applicants: ${job.applicantsCount ?? 0}'),
                      ],
                    ),
                  ],
                ),
              ),

              // Client Profile
              const Text(
                'Client Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              FutureBuilder<DocumentSnapshot>(
                future: job.postedBy != null
                    ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(job.postedBy)
                    .get()
                    : null,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData ||
                      !snapshot.data!.exists) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final clientData = snapshot.data!.data() as Map<String, dynamic>;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.05),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurpleAccent,
                        child: Text(clientData['firstName']?[0] ?? '?'),
                      ),
                      title: Text(
                          '${clientData['firstName']} ${clientData['lastName']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${clientData['email']}'),
                          Text('Phone: ${clientData['phoneNumber']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Description
              const Text(
                'Description',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Text(
                  job.description ?? 'No description provided.',
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 30),

              // Action Button
              Align(
                alignment: Alignment.center,
                child: isFreelancer
                    ? ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('applications')
                          .add({
                        'jobId': jobId,
                        'freelancerId': userId,
                        'status': 'pending',
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Application submitted successfully')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error applying for job: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.assignment_turned_in_rounded),
                  label: const Text('Apply Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF062D8A),
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                )
                    : ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MessagesScreen(
                          jobId: jobId,
                          otherUserId: job.postedBy,
                          userId: userId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.message_rounded),
                  label: const Text('Chat with Freelancer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8800FC),
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}