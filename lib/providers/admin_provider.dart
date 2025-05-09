import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> approveUser(String userId) async {
    await _firestore.collection('users').doc(userId).update({'verificationStatus': 'approved'});
  }

  Future<void> rejectUser(String userId) async {
    await _firestore.collection('users').doc(userId).update({'verificationStatus': 'rejected'});
  }

  Future<void> addJobCategory(String category) async {
    await _firestore.collection('jobCategories').add({'name': category});
  }

  Future<void> deleteJobCategory(String categoryId) async {
    await _firestore.collection('jobCategories').doc(categoryId).delete();
  }

  Future<void> postAnnouncement(String message) async {
    await _firestore.collection('announcements').add({
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resolveReport(String reportId) async {
    await _firestore.collection('reports').doc(reportId).update({'status': 'resolved'});
  }
}