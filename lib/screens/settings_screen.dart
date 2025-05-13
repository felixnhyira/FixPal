import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For local storage
import 'package:fixpal/screens/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/constants.dart'; // Import LoginScreen

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Log out the user and clear saved credentials
  Future<void> _logoutUser(BuildContext context) async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();

    try {
      // Clear saved credentials
      await prefs.remove('email');
      await prefs.remove('password');

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Navigate back to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppConstants.primaryBlue, AppConstants.secondaryPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Settings'),
          foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Light/Dark Mode'),
            trailing: Switch(
              value: true, // Replace with actual theme state
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Theme is ${value ? 'on' : 'off'}')),
                );
              },
            ),
          ),
          ListTile(
            title: const Text('Sound Notifications'),
            trailing: Switch(
              value: true, // Replace with actual notification state
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sound notifications are ${value ? 'on' : 'off'}')),
                );
              },
            ),
          ),
          ListTile(
            title: const Text('About FixPal'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Check for Updates'),
            onTap: () async {
              const url = 'https://play.google.com/store/apps/details?id=com.fixpal'; // Replace with your app's Play Store URL
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open the app store')),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              _logoutUser(context); // Trigger logout
            },
          ),
        ],
      ),
    );
  }
}

// About Screen
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About FixPal'),
        backgroundColor: const Color(0xFF062D8A), // Primary blue color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FixPal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Version: 1.0.0'),
            const SizedBox(height: 20),
            const Text(
              'FixPal is a gig economy platform connecting clients with skilled freelancers.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Developed by Your Team Name',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}