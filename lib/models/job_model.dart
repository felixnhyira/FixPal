import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  String? jobId; // Unique identifier for the job
  String? title; // Job title
  String? description; // Job description
  String? category; // Job category (e.g., Carpenter, Plumber)
  String? region; // Region where the job is located
  String? city; // City/Constituency where the job is located
  DateTime? deadline; // Deadline for the job
  String? postedBy; // User ID of the client who posted the job
  String? status; // Job status: 'open', 'assigned', 'completed'
  String? imageUrl; // URL of the uploaded image (optional)
  String? videoUrl; // URL of the uploaded video (optional)
  DateTime? timestamp; // Timestamp when the job was posted
  int? applicantsCount; // Number of applicants
  bool? isFeatured;

  /// Constructor for JobModel
  JobModel({
    this.jobId,
    this.title,
    this.description,
    this.category,
    this.region,
    this.city,
    this.deadline,
    this.postedBy,
    this.status,
    this.imageUrl,
    this.videoUrl,
    this.timestamp,
    this.applicantsCount = 0, // Default to 0 if not set
    bool? isFeatured,
  });

  /// Convert Firestore document to JobModel
  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      jobId: map['jobId'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      region: map['region'], // Added region field
      city: map['city'], // Added city field
      deadline: (map['deadline'] as Timestamp?)?.toDate(),
      postedBy: map['postedBy'],
      status: map['status'],
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
      applicantsCount: map['applicantsCount']?.toInt() ?? 0, // Default to 0 if not set
      isFeatured: map['isFeatured'] ?? false,
    );
  }

  /// Convert JobModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'title': title,
      'description': description,
      'category': category,
      'region': region,
      'city': city,
      'deadline': deadline != null ? FieldValue.serverTimestamp() : null,
      'postedBy': postedBy,
      'status': status,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'timestamp': timestamp != null ? FieldValue.serverTimestamp() : null,
      'applicantsCount': applicantsCount,
      'isFeatured': isFeatured, 

    };
  }
}