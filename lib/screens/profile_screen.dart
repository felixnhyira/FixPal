import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fixpal/screens/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  Future<void> _resendVerificationEmail(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    return FutureBuilder<DocumentSnapshot>(
      future: firestore.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User not found')),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: const Color(0xFF062D8A),
            actions: [
              if (auth.currentUser?.uid == userId)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(userId: userId),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            userData['profilePhotoUrl'] ?? '',
                          ),
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          child: userData['profilePhotoUrl'] == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${userData['firstName'] ?? 'N/A'} ${userData['lastName'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (auth.currentUser?.uid == userId)
                          _buildVerificationStatus(context, userData),

                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // User Details Section
                  const Text(
                    'Account Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildDetailItem('Email', userData['email'] ?? 'N/A'),
                  _buildDetailItem('Phone', userData['phoneNumber'] ?? 'N/A'),
                  _buildDetailItem('Role', userData['role'] ?? 'N/A'),
                  _buildDetailItem('Region', userData['region'] ?? 'N/A'),
                  _buildDetailItem('City', userData['city'] ?? 'N/A'),
                  _buildDetailItem(
                    'Ghana Card',
                    userData['ghanaCardNumber'] ?? 'N/A',
                  ),
                  _buildDetailItem(
                    'Date of Birth',
                    userData['dob'] ?? 'N/A',
                  ),
                  const SizedBox(height: 24),

                  // Professional Information (for freelancers)
                  if (userData['role'] == 'Freelancer') ...[
                    const Text(
                      'Professional Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _buildDetailItem(
                      'Job Category',
                      userData['jobCategory'] ?? 'N/A',
                    ),
                    if (userData['certificateUrl'] != null)
                      _buildDocumentButton(
                        'View Certificate',
                        userData['certificateUrl'],
                      ),
                    if (userData['cvUrl'] != null)
                      _buildDocumentButton(
                        'View CV',
                        userData['cvUrl'],
                      ),
                    const SizedBox(height: 24),
                  ],

                  // Reviews Section
                  const Text(
                    'Reviews',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildReviewsSection(firestore),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentButton(String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton(
        onPressed: () {
          // Implement document viewer
        },
        child: Text(label),
      ),
    );
  }

  Widget _buildVerificationStatus(BuildContext context, Map<String, dynamic> userData)
 {
    final isCurrentUser = FirebaseAuth.instance.currentUser?.uid == userId;
    final phoneVerified = userData['phoneVerified'] ?? false;
    final emailVerified = userData['emailVerified'] ?? false;

    return Column(
      children: [
        const SizedBox(height: 8),
        if (isCurrentUser) ...[
          ListTile(
            leading: Icon(
              emailVerified ? Icons.verified : Icons.warning,
              color: emailVerified ? Colors.green : Colors.orange,
            ),
            title: const Text('Email Verification'),
            subtitle: Text(
              emailVerified ? 'Verified' : 'Not Verified',
              style: TextStyle(
                color: emailVerified ? Colors.green : Colors.orange,
              ),
            ),
            trailing: !emailVerified
                ? TextButton(
                    onPressed: () => _resendVerificationEmail(context),
                    child: const Text('Resend'),
                  )
                : null,
          ),
          ListTile(
            leading: Icon(
              phoneVerified ? Icons.verified : Icons.warning,
              color: phoneVerified ? Colors.green : Colors.orange,
            ),
            title: const Text('Phone Verification'),
            subtitle: Text(
              phoneVerified ? 'Verified' : 'Not Verified',
              style: TextStyle(
                color: phoneVerified ? Colors.green : Colors.orange,
              ),
            ),
            trailing: !phoneVerified
                ? TextButton(
                    onPressed: () {
                      // Implement phone verification flow
                    },
                    child: const Text('Verify'),
                  )
                : null,
          ),
          const SizedBox(height: 8),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified,
                color: emailVerified ? Colors.green : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Email ${emailVerified ? 'Verified' : 'Not Verified'}',
                style: TextStyle(
                  color: emailVerified ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.verified,
                color: phoneVerified ? Colors.green : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Phone ${phoneVerified ? 'Verified' : 'Not Verified'}',
                style: TextStyle(
                  color: phoneVerified ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildReviewsSection(FirebaseFirestore firestore) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('reviews')
          .where('revieweeId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No reviews yet',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final reviews = snapshot.data!.docs;
        double averageRating = 0;

        if (reviews.isNotEmpty) {
          final total = reviews.fold(
              0.0,
              (sum, doc) =>
                  sum + (doc.data() as Map<String, dynamic>)['rating']);
          averageRating = total / reviews.length;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 4),
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'})',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final review = reviews[index].data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          for (int i = 0; i < 5; i++)
                            Icon(
                              Icons.star,
                              color: i < (review['rating'] as int)
                                  ? Colors.amber
                                  : Colors.grey,
                              size: 16,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM d, yyyy').format(
                              (review['timestamp'] as Timestamp).toDate(),
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (review['comment'] != null)
                        Text(
                          review['comment'],
                          style: const TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}