import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  final String title;
  final String category;
  final String location;
  final String deadline;
  final VoidCallback onView;

  const JobCard({super.key, 
    required this.title,
    required this.category,
    required this.location,
    required this.deadline,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        onTap: onView,
        leading: Icon(Icons.work, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: $category'),
            Text('Location: $location'),
            Text('Deadline: $deadline'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onView,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Text('View'),
        ),
      ),
    );
  }
}