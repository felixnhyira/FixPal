import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  String? reviewId;
  String? reviewerId; // ID of the person leaving the review
  String? revieweeId; // ID of the person being reviewed
  String? jobId; // The job associated with the review
  int? rating; // 1-5 stars
  String? comment; // Optional comment
  DateTime? timestamp;

  ReviewModel({
    this.reviewId,
    this.reviewerId,
    this.revieweeId,
    this.jobId,
    this.rating,
    this.comment,
    this.timestamp,
  });

  // Factory method to create a ReviewModel from Firestore snapshot
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      reviewId: map['reviewId'],
      reviewerId: map['reviewerId'],
      revieweeId: map['revieweeId'],
      jobId: map['jobId'],
      rating: map['rating'],
      comment: map['comment'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  // Method to convert ReviewModel to a Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'reviewerId': reviewerId,
      'revieweeId': revieweeId,
      'jobId': jobId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
}