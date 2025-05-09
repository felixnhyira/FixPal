import 'package:cloud_firestore/cloud_firestore.dart';

class JobProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> postJob(String title, String description, String category, String location, DateTime deadline) async {
    await _firestore.collection('jobs').add({
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'deadline': deadline,
      'status': 'open',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> fetchJobListings() {
    return _firestore.collection('jobs').snapshots();
  }

  Future<void> applyForJob(String jobId, String freelancerId) async {
    await _firestore.collection('applications').add({
      'jobId': jobId,
      'freelancerId': freelancerId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}