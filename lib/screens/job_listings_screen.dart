import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore database
import 'package:intl/intl.dart'; // For date formatting
import 'package:fixpal/models/job_model.dart'; // Import JobModel
import 'package:fixpal/screens/job_details_screen.dart'; // Import JobDetailsScreen
import 'package:fixpal/utils/constants.dart'; // Import constants

class JobListingsScreen extends StatefulWidget {
  final String? userId; // Optional: Pass user ID if needed

  const JobListingsScreen({super.key, this.userId});

  @override
  _JobListingsScreenState createState() => _JobListingsScreenState();
}

class _JobListingsScreenState extends State<JobListingsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedCategory; // Selected job category
  String? _selectedRegion; // Selected region
  String? _selectedCity; // Selected city

// Initial query

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Jobs'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF062D8A), Color(0xFF8800FC)], // Blue-Purple gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showFilterDialog(context); // Open the filter dialog
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getFilteredJobsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading indicator while fetching
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Display error message
          }

          final List<QueryDocumentSnapshot> jobs = snapshot.data!.docs;

          if (jobs.isEmpty) {
            return const Center(child: Text('No jobs available')); // Fallback message for empty results
          }

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
                        'Deadline: ${_formatDate(job.deadline)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Applicants: ${job.applicantsCount ?? 0}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailsScreen(
                            jobId: jobs[index].id, // Pass job ID
                            userId: widget.userId ?? '', // Pass current user ID
                            isFreelancer: widget.userId != null ? true : false, jobData: {}, // Assume Freelancer if user ID is passed
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF062D8A), // Primary blue color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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

  /// Fetches filtered jobs from Firestore
  Stream<QuerySnapshot> _getFilteredJobsStream() {
    Query query = _firestore.collection('jobs');

    if (_selectedCategory != null) {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    if (_selectedRegion != null) {
      query = query.where('region', isEqualTo: _selectedRegion);
    }

    if (_selectedCity != null) {
      query = query.where('city', isEqualTo: _selectedCity);
    }

    return query.orderBy('timestamp', descending: true).snapshots(); // Order by timestamp
  }

  /// Formats the deadline date safely
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

  /// Shows the filter dialog for refining job listings
  void showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Jobs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: AppConstants.jobCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value; // Update selected category
                  });
                },
                decoration: const InputDecoration(labelText: 'Job Category'),
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _selectedRegion,
                items: AppConstants.regionsAndCities.keys.map((region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRegion = value; // Update selected region
                    _selectedCity = null; // Reset city when region changes
                  });
                },
                decoration: const InputDecoration(labelText: 'Region'),
              ),
              const SizedBox(height: 10),

              if (_selectedRegion != null)
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  items: AppConstants.regionsAndCities[_selectedRegion]?.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value; // Update selected city
                    });
                  },
                  decoration: const InputDecoration(labelText: 'City'),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog without applying filters
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Apply filters and close dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF062D8A), // Primary blue color
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply Filters'), // Ensure 'child' is last
            ),
          ],
        );
      },
    );
  }
}