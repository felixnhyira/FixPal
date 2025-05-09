import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ProfileProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Updates the profile of a user in Firestore.
  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      // Handle errors (e.g., document does not exist, network issues)
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      rethrow; // Re-throw the error so the caller can handle it
    }
  }

  /// Fetches the profile of a user from Firestore.
  Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data(); // Safely cast to Map
      }
      return null; // Return null if the document does not exist
    } catch (e) {
      // Handle errors (e.g., network issues)
      if (kDebugMode) {
        print('Error fetching user profile: $e');
      }
      return null;
    }
  }

  /// Convenience method to get the current user's ID from Firebase Auth.
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Updates the profile of the currently authenticated user.
  Future<void> updateCurrentUserProfile(Map<String, dynamic> updates) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('No user is currently logged in.');
    }
    await updateProfile(userId, updates);
  }

  /// Fetches the profile of the currently authenticated user.
  Future<Map<String, dynamic>?> fetchCurrentUserProfile() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('No user is currently logged in.');
    }
    return await fetchUserProfile(userId);
  }
}