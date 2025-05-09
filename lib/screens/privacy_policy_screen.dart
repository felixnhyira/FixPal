import 'package:flutter/material.dart';
import 'package:fixpal/utils/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppConstants.primaryBlue, AppConstants.secondaryPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F7FA)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryBlue.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Last Updated: April 5, 2025',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppConstants.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header with icon
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.privacy_tip_outlined,
                      size: 60,
                      color: AppConstants.primaryBlue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'FixPal Privacy Policy',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1.2, color: Colors.grey),

              _buildSectionTitle('1. Introduction'),
              _buildParagraph(
                'Welcome to FixPal ("we", "our", or "the App"). We are committed to protecting your personal information and ensuring transparency in how we collect, use, and share your data. This Privacy Policy explains our practices regarding data collected through the FixPal mobile application.',
              ),

              _buildSectionTitle('2. Information We Collect'),
              _buildParagraph(
                'We collect the following types of information when you use FixPal:',
              ),
              _buildBulletPoint('Personal Information: First name, last name, email address, phone number.'),
              _buildBulletPoint('Identification: Ghana Card Number (for verification)'),
              _buildBulletPoint('Location: Region and city you operate in.'),
              _buildBulletPoint('Role: Whether you are a freelancer or client.'),
              _buildBulletPoint('Job Preferences: For freelancers (e.g., category).'),
              _buildBulletPoint('Media Files: Profile photo, ID image, CV, certificate.'),
              _buildBulletPoint('Device Data: IP address, device type, OS version.'),

              _buildSectionTitle('3. How We Use Your Information'),
              _buildParagraph(
                'We use your data to provide and improve FixPal services, including:',
              ),
              _buildBulletPoint('Creating and managing your account.'),
              _buildBulletPoint('Verifying your identity and role.'),
              _buildBulletPoint('Facilitating job postings and applications.'),
              _buildBulletPoint('Improving user experience and app functionality.'),
              _buildBulletPoint('Ensuring security and preventing fraud.'),
              _buildBulletPoint('Complying with legal obligations.'),

              _buildSectionTitle('4. Sharing Your Information'),
              _buildParagraph(
                'We do not sell your personal data to third parties. However, your information may be shared in the following scenarios:',
              ),
              _buildBulletPoint('With freelancers and clients for job-related communication.'),
              _buildBulletPoint('With service providers who assist in app operations.'),
              _buildBulletPoint('For legal compliance or protection of rights.'),
              _buildBulletPoint('With your consent or as otherwise described.'),

              _buildSectionTitle('5. Data Retention'),
              _buildParagraph(
                'Your data is retained while your account is active or as needed to provide services, comply with legal obligations, resolve disputes, and enforce agreements.',
              ),

              _buildSectionTitle('6. Your Data Rights'),
              _buildParagraph(
                'You have the right to access, update, or delete your personal information. You can manage this through your account settings or by contacting support.',
              ),

              _buildSectionTitle('7. Security'),
              _buildParagraph(
                'We implement industry-standard security measures to protect your data against unauthorized access, alteration, or destruction.',
              ),

              _buildSectionTitle('8. Changes to This Policy'),
              _buildParagraph(
                'We may update this Privacy Policy from time to time. The updated version will be posted on this screen with a new "Last Updated" date.',
              ),

              _buildSectionTitle('9. Contact Us'),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryBlue.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.primaryBlue.withAlpha(60)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContactItem(Icons.email, 'support@fixpal.com'),
                    const SizedBox(height: 8),
                    _buildContactItem(Icons.phone, '+233 546 296 531'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3, right: 8),
            child: Icon(
              Icons.circle,
              size: 8,
              color: AppConstants.primaryBlue,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppConstants.primaryBlue),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}