import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixpal/models/user_model.dart';
import 'package:fixpal/models/job_model.dart';
import 'package:fixpal/models/message_model.dart';
import 'package:fixpal/models/review_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new user to Firestore
  Future<void> addUser(UserModel user) async {
    await _firestore.collection('users').doc(user.userId).set(user.toFirestore());
  }

  // Update user details in Firestore
  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.userId).update(user.toFirestore());
  }

  // Get user details from Firestore
  Future<UserModel?> getUser(String userId) async {
    final docSnapshot = await _firestore.collection('users').doc(userId).get();
    if (docSnapshot.exists) {
      return UserModel.fromFirestore(docSnapshot.data()! as DocumentSnapshot<Object?>);
    }
    return null;
  }

  // Add a new job posting to Firestore
  Future<void> addJob(JobModel job) async {
    await _firestore.collection('jobs').doc(job.jobId).set(job.toMap());
  }

  // Update job details in Firestore
  Future<void> updateJob(JobModel job) async {
    await _firestore.collection('jobs').doc(job.jobId).update(job.toMap());
  }

  // Get job postings from Firestore
  Stream<QuerySnapshot> getJobs() {
    return _firestore.collection('jobs').snapshots();
  }

  // Add a new message to Firestore
  Future<void> addMessage(MessageModel message) async {
    await _firestore.collection('messages').add(message.toMap());
  }

  // Get messages for a specific job from Firestore
  Stream<QuerySnapshot> getMessagesForJob(String jobId) {
    return _firestore
        .collection('messages')
        .where('jobId', isEqualTo: jobId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Add a new review to Firestore
  Future<void> addReview(ReviewModel review) async {
    await _firestore.collection('reviews').add(review.toMap());
  }

  // Get reviews for a specific user from Firestore
  Stream<QuerySnapshot> getReviewsForUser(String userId) {
    return _firestore
        .collection('reviews')
        .where('revieweeId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}