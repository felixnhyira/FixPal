import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a file to Firebase Storage
  Future<String> uploadFile(String filePath, String fileName) async {
    try {
      File file = File(filePath);
      Reference ref = _storage.ref().child('uploads/$fileName');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  // Delete a file from Firebase Storage
  Future<void> deleteFile(String filePath) async {
    try {
      Reference ref = _storage.refFromURL(filePath);
      await ref.delete();
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }
}
