import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String description;
  final String reportedBy;
  final String reportedByName;
  final String status;
  final DateTime timestamp;
  final DateTime? resolvedAt;
  final String category;
  final List<String> images;

  Report({
    required this.id,
    required this.description,
    required this.reportedBy,
    required this.reportedByName,
    this.status = 'pending',
    required this.timestamp,
    this.resolvedAt,
    required this.category,
    this.images = const [],
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      description: data['description'],
      reportedBy: data['reportedBy'],
      reportedByName: data['reportedByName'],
      status: data['status'] ?? 'pending',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      resolvedAt: data['resolvedAt'] != null 
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
      category: data['category'] ?? 'general',
      images: List<String>.from(data['images'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'reportedBy': reportedBy,
      'reportedByName': reportedByName,
      'status': status,
      'timestamp': timestamp,
      if (resolvedAt != null) 'resolvedAt': resolvedAt,
      'category': category,
      'images': images,
    };
  }
}