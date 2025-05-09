import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitReview(String jobId, String revieweeId, int rating, String comment) async {
    await _firestore.collection('reviews').add({
      'reviewerId': _auth.currentUser!.uid,
      'revieweeId': revieweeId,
      'jobId': jobId,
      'rating': rating,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getReviews(String revieweeId) {
    return _firestore
        .collection('reviews')
        .where('revieweeId', isEqualTo: revieweeId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}