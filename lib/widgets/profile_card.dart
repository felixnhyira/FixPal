import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final String? profilePhotoUrl;

  const ProfileCard({
    super.key,
    required this.name,
    required this.role,
    this.profilePhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(profilePhotoUrl ?? ''),
        ),
        title: Text(name),
        subtitle: Text(role),
        trailing: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('View Profile')));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF062D8A),
            foregroundColor: Colors.white,
          ),
          child: Text('View'),
        ),
      ),
    );
  }
}