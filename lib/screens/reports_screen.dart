import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('reports').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> reports = snapshot.data!.docs;

        if (reports.isEmpty) {
          return Center(child: Text("No reports available."));
        }

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            var reportData = reports[index].data() as Map<String, dynamic>;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: ListTile(
                title: Text(reportData['description'] ?? 'No Description'),
                subtitle: Text('Reported by: ${reportData['reportedBy'] ?? 'Unknown'}'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await _firestore.collection('reports').doc(reports[index].id).update({
                      'status': 'resolved',
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report resolved')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Resolve'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}