import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  String? applicationId; // Unique identifier for the application
  String? jobId; // Job posting ID
  String? freelancerId; // Freelancer's user ID
  String? clientId; // Client's user ID
  String? status; // Application status: 'pending', 'approved', 'rejected', or 'hired'
  DateTime? submittedAt; // Timestamp when the application was submitted
  DateTime? updatedAt; // Timestamp when the application status was last updated

  ApplicationModel({
    this.applicationId,
    this.jobId,
    this.freelancerId,
    this.clientId,
    this.status,
    this.submittedAt,
    this.updatedAt,
  });

  // Factory method to create an ApplicationModel from a Firestore snapshot
  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      applicationId: map['applicationId'],
      jobId: map['jobId'],
      freelancerId: map['freelancerId'],
      clientId: map['clientId'],
      status: map['status'] ?? 'pending', // Default status is 'pending'
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate(), // Convert Firestore Timestamp to DateTime
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(), // Convert Firestore Timestamp to DateTime
    );
  }

  // Method to convert ApplicationModel to a Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'applicationId': applicationId,
      'jobId': jobId,
      'freelancerId': freelancerId,
      'clientId': clientId,
      'status': status,
      'submittedAt': submittedAt != null ? FieldValue.serverTimestamp() : null, // Save as Firestore Timestamp
      'updatedAt': updatedAt != null ? FieldValue.serverTimestamp() : null, // Save as Firestore Timestamp
    };
  }
}