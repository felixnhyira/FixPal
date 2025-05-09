import 'package:fixpal/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For user authentication
import 'package:fixpal/screens/job_listings_screen.dart'; // Import JobListingsScreen
import 'package:fixpal/screens/proposals_screen.dart'; // Import ProposalsScreen
import 'package:fixpal/screens/profile_screen.dart'; // Import ProfileScreen

class FreelancerDashboard extends StatelessWidget {
  const FreelancerDashboard({super.key});

  /// Fetch the current user's ID from Firebase Authentication
  Future<String?> _getUserId() async {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserId(), // Fetch the user ID
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final String? userId = snapshot.data;

        if (userId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          });
          return const SizedBox(); // Prevent unnecessary UI rendering
        }

        return DefaultTabController(
          length: 3, // Number of tabs
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Freelancer Dashboard'),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF062D8A), Color(0xFF8800FC)], // Blue-Purple gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Find Jobs'), // Navigate to JobListingsScreen
                  Tab(text: 'Proposals'), // Navigate to ProposalsScreen
                  Tab(text: 'Profile'), // Navigate to ProfileScreen
                ],
              ),
            ),
            body: TabBarView(
              children: [
                JobListingsScreen(userId: userId), // Pass user ID to JobListingsScreen
                ProposalsScreen(userId: userId), // Pass user ID to ProposalsScreen
                ProfileScreen(userId: userId), // Pass user ID to ProfileScreen
              ],
            ),
          ),
        );
      },
    );
  }
}