import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobManagementScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  JobManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Add New Job Category',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) async {
              if (value.trim().isNotEmpty) {
                await _firestore.collection('jobCategories').add({'name': value.trim()});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category added')));
              }
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('jobCategories').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              List<QueryDocumentSnapshot> categories = snapshot.data!.docs;

              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  var categoryData = categories[index].data() as Map<String, dynamic>;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      title: Text(categoryData['name']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _firestore.collection('jobCategories').doc(categories[index].id).delete();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category deleted')));
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}