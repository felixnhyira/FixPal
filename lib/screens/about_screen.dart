import 'package:flutter/material.dart';
import 'package:fixpal/utils/constants.dart';
import '../widgets/app_bar_gradient.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarGradient(
        title: const Text(
          'About FixPal',
          style: TextStyle(color: AppConstants.white),
        ),
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
              'Developed by FixPal Team',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}