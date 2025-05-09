import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String role; // 'freelancer', 'client', or 'admin'
  final String? region;
  final String? city;
  final String? profilePhotoUrl;
  final String? idImageUrl;
  final String verificationStatus; // 'pending', 'approved', 'rejected'
  final String? jobCategory; // For freelancers
  final String? cvUrl;
  final String? certificateUrl;
  final String? companyName;
  final String? companyRegistrationNumber;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final bool isActive;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.role,
    this.region,
    this.city,
    this.profilePhotoUrl,
    this.idImageUrl,
    this.verificationStatus = 'pending',
    this.jobCategory,
    this.cvUrl,
    this.certificateUrl,
    this.companyName,
    this.companyRegistrationNumber,
    required this.createdAt,
    this.verifiedAt,
    this.isActive = true,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      userId: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'client',
      region: data['region'],
      city: data['city'],
      profilePhotoUrl: data['profilePhotoUrl'],
      idImageUrl: data['idImageUrl'],
      verificationStatus: data['verificationStatus'] ?? 'pending',
      jobCategory: data['jobCategory'],
      cvUrl: data['cvUrl'],
      certificateUrl: data['certificateUrl'],
      companyName: data['companyName'],
      companyRegistrationNumber: data['companyRegistrationNumber'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      verifiedAt: data['verifiedAt'] != null
          ? (data['verifiedAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role,
      if (region != null) 'region': region,
      if (city != null) 'city': city,
      if (profilePhotoUrl != null) 'profilePhotoUrl': profilePhotoUrl,
      if (idImageUrl != null) 'idImageUrl': idImageUrl,
      'verificationStatus': verificationStatus,
      if (jobCategory != null) 'jobCategory': jobCategory,
      if (cvUrl != null) 'cvUrl': cvUrl,
      if (certificateUrl != null) 'certificateUrl': certificateUrl,
      if (companyName != null) 'companyName': companyName,
      if (companyRegistrationNumber != null)
        'companyRegistrationNumber': companyRegistrationNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      if (verifiedAt != null) 'verifiedAt': Timestamp.fromDate(verifiedAt!),
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? role,
    String? region,
    String? city,
    String? profilePhotoUrl,
    String? idImageUrl,
    String? verificationStatus,
    String? jobCategory,
    String? cvUrl,
    String? certificateUrl,
    String? companyName,
    String? companyRegistrationNumber,
    DateTime? verifiedAt,
    bool? isActive,
  }) {
    return UserModel(
      userId: userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      role: role ?? this.role,
      region: region ?? this.region,
      city: city ?? this.city,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      idImageUrl: idImageUrl ?? this.idImageUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      jobCategory: jobCategory ?? this.jobCategory,
      cvUrl: cvUrl ?? this.cvUrl,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      companyName: companyName ?? this.companyName,
      companyRegistrationNumber:
      companyRegistrationNumber ?? this.companyRegistrationNumber,
      createdAt: createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}