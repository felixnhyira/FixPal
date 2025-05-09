import 'package:flutter/material.dart';

import '../utils/constants.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
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
        elevation: 0,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE8F4F8)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/icons/terms_icon.png',
                    height: 80,
                    width: 80,
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'FixPal Terms of Service',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Last Updated: May 2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(thickness: 1.5),
                const SizedBox(height: 16),
                _buildSectionTitle("1. Acceptance of Terms"),
                _buildSectionContent(
                    "By accessing or using FixPal, you agree to be bound by these Terms. If you do not agree, you must not use the platform."),
                _buildSectionTitle("2. User Eligibility"),
                _buildBulletPoint("You must be at least 18 years old to use FixPal"),
                _buildBulletPoint("You must provide accurate and complete registration details"),
                _buildBulletPoint("Accounts must not be shared or transferred"),
                _buildSectionTitle("3. User Responsibilities"),
                _buildSubSectionTitle("Freelancers:"),
                _buildBulletPoint("Must provide honest information about skills and experience"),
                _buildBulletPoint("Must complete jobs as agreed with clients"),
                _buildBulletPoint("Must not engage in fraudulent activities"),
                _buildSubSectionTitle("Clients:"),
                _buildBulletPoint("Must provide clear job descriptions"),
                _buildBulletPoint("Must not request free work outside agreed terms"),
                _buildBulletPoint("Must pay freelancers as agreed"),
                _buildSectionTitle("4. Job Posting & Applications"),
                _buildBulletPoint("Clients must not post illegal or misleading jobs"),
                _buildBulletPoint("Freelancers must not submit fake applications"),
                _buildBulletPoint("FixPal reserves the right to remove violating content"),
                _buildSectionTitle("5. Payments & Fees"),
                _buildBulletPoint("FixPal may charge service fees for transactions"),
                _buildBulletPoint("Disputes should be resolved directly between parties"),
                _buildBulletPoint("FixPal is not responsible for external payment issues"),
                _buildSectionTitle("6. Privacy & Data Use"),
                _buildBulletPoint("User data is protected under our Privacy Policy"),
                _buildBulletPoint("We may use non-personal data for analytics"),
                _buildSectionTitle("7. Prohibited Conduct"),
                _buildWarningPoint("Harass, scam, or deceive others"),
                _buildWarningPoint("Post illegal or harmful content"),
                _buildWarningPoint("Impersonate others or use fake accounts"),
                _buildWarningPoint("Circumvent payments outside FixPal"),
                _buildSectionTitle("8. Account Termination"),
                _buildBulletPoint("Violating these Terms may result in termination"),
                _buildBulletPoint("Fraudulent behavior will not be tolerated"),
                _buildBulletPoint("Inactive accounts may be deactivated"),
                _buildSectionTitle("9. Limitation of Liability"),
                _buildBulletPoint("FixPal is not liable for job disputes"),
                _buildBulletPoint("Not responsible for service interruptions"),
                _buildBulletPoint("Not liable for unauthorized account access"),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo.withAlpha(76)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Contact Us",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildContactInfo(Icons.email, "support@fixpal.com"),
                      _buildContactInfo(Icons.phone, "+233546296531"),
                      const SizedBox(height: 8),
                      const Text(
                        "© 2025 FixPal. All rights reserved.",
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      "I Understand",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  static Widget _buildSubSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  static Widget _buildSectionContent(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }

  static Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3, right: 8),
            child: Icon(
              Icons.circle,
              size: 8,
              color: Colors.blueGrey,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildWarningPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3, right: 8),
            child: Icon(
              Icons.warning_rounded,
              size: 16,
              color: Colors.orange,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildContactInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.indigo),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
