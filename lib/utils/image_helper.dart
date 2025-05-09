import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class ImageHelper {
  // Pick image from gallery
  static Future<File?> pickImageFromGallery({
    bool crop = true,
    CropAspectRatioPreset aspectRatio = CropAspectRatioPreset.original,
    int compressQuality = 70,
  }) async {
    return await _pickImage(
      source: ImageSource.gallery,
      crop: crop,
      aspectRatio: aspectRatio,
      compressQuality: compressQuality,
    );
  }

  // Take photo using the camera
  static Future<File?> takePhoto({
    bool crop = true,
    CropAspectRatioPreset aspectRatio = CropAspectRatioPreset.original,
    int compressQuality = 70,
  }) async {
    return await _pickImage(
      source: ImageSource.camera,
      crop: crop,
      aspectRatio: aspectRatio,
      compressQuality: compressQuality,
    );
  }

  // Internal method for picking and optionally cropping image
  static Future<File?> _pickImage({
    required ImageSource source,
    bool crop = true,
    CropAspectRatioPreset aspectRatio = CropAspectRatioPreset.original,
    int compressQuality = 70,
  }) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) return null;

      if (!crop) {
        return File(pickedFile.path);
      }

      final croppedFile = await _cropImage(
        pickedFile.path,
        aspectRatio,
        compressQuality,
      );

      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      debugPrint("[ImageHelper] Error: $e");
      return null;
    }
  }

  // Crop image using ImageCropper
  static Future<CroppedFile?> _cropImage(
      String imagePath,
      CropAspectRatioPreset aspectRatio,
      int compressQuality,
      ) async {
    return await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: _getCustomAspectRatio(aspectRatio),
      compressQuality: compressQuality,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: aspectRatio,
          lockAspectRatio: aspectRatio != CropAspectRatioPreset.original,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );
  }

  // Helper to convert preset to custom ratio if needed
  static CropAspectRatio? _getCustomAspectRatio(CropAspectRatioPreset preset) {
    if (preset == CropAspectRatioPreset.square) {
      return const CropAspectRatio(ratioX: 1, ratioY: 1);
    }
    return null; // Let the cropper handle original/free aspect ratios
  }
}