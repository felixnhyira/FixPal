import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserVerificationScreen extends StatelessWidget {
  final String adminId;

  const UserVerificationScreen({super.key, required this.adminId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where('verificationStatus', isEqualTo: 'pending').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return Center(child: Text('No pending users for verification'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text('${userData['firstName']} ${userData['lastName']}'),
                subtitle: Text('Email: ${userData['email']} | Role: ${userData['role']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('users').doc(users[index].id).update({
                          'verificationStatus': 'approved',
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User approved')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Approve'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('users').doc(users[index].id).update({
                          'verificationStatus': 'rejected',
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User rejected')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Reject'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}