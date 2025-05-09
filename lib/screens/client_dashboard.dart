import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixpal/screens/hired_freelancers_screen.dart';
import 'package:fixpal/screens/proposals_received_screen.dart';
import 'package:flutter/material.dart';
import 'package:fixpal/screens/job_posting_screen.dart';
import 'package:fixpal/screens/profile_screen.dart';

class ClientDashboard extends StatelessWidget {
  const ClientDashboard({super.key});

  @override
Widget build(BuildContext context) {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
    });
    return const Center(child: CircularProgressIndicator());
  }

  return DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Client Dashboard'),
        backgroundColor: const Color(0xFF062D8A),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Post a Job'),
            Tab(text: 'Proposals Received'),
            Tab(text: 'Hired Freelancers'),
            Tab(text: 'Profile'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          JobPostingScreen(userId: userId),
          ProposalsReceivedScreen(clientId: userId),
          HiredFreelancersScreen(clientId: userId),
          ProfileScreen(userId: userId),
        ],
      ),
    ),
  );
}
}