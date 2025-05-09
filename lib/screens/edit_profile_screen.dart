import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:fixpal/utils/constants.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;

  const EditProfileScreen({super.key, required this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ghanaCardController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _selectedRegion;
  String? _selectedCity;
  String? _jobCategory;
  File? _idImageFile;
  File? _profilePhotoFile;
  File? _cvFile;
  File? _certificateFile;
  bool _isLoading = false;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      _isCurrentUser = currentUser?.uid == widget.userId;
    });
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _phoneController.text = data['phoneNumber']?.replaceFirst('+233', '0') ?? '';
          _ghanaCardController.text = data['ghanaCardNumber'] ?? '';
          _dobController.text = data['dob'] ?? '';
          _selectedRegion = data['region'];
          _selectedCity = data['city'];
          _jobCategory = data['jobCategory'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndCropImage(ImageSource source, String type) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: type == 'profile' 
              ? const CropAspectRatio(ratioX: 1, ratioY: 1)
              : null,
          compressQuality: 70,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: const Color(0xFF062D8A),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: type == 'profile',
            ),
            IOSUiSettings(
              title: 'Crop Image',
              aspectRatioLockEnabled: type == 'profile',
            ),
          ],
        );

        if (croppedFile != null && mounted) {
          setState(() {
            if (type == 'id') {
              _idImageFile = File(croppedFile.path);
            } else if (type == 'profile') {
              _profilePhotoFile = File(croppedFile.path);
            } else if (type == 'certificate') {
              _certificateFile = File(croppedFile.path);
            } else if (type == 'cv') {
              _cvFile = File(croppedFile.path);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image selection failed: $e')),
        );
      }
    }
  }

  Future<String?> _uploadFile(File? file, String path) async {
    if (file == null) return null;
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_uploads/$path/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File upload failed: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isCurrentUser) return;

    setState(() => _isLoading = true);
    try {
      // Upload files
      final profileUrl = await _uploadFile(
          _profilePhotoFile, 'profile_${widget.userId}');
      final idUrl = await _uploadFile(_idImageFile, 'id_${widget.userId}');
      final cvUrl = await _uploadFile(_cvFile, 'cv_${widget.userId}');
      final certificateUrl = await _uploadFile(
          _certificateFile, 'certificate_${widget.userId}');

      // Prepare update data
      final updateData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'ghanaCardNumber': _ghanaCardController.text.trim(),
        'region': _selectedRegion,
        'city': _selectedCity,
        'dob': _dobController.text,
        'updatedAt': FieldValue.serverTimestamp(),
        'verificationStatus': 'pending', // Require re-verification
      };

      // Add optional fields
      if (_jobCategory != null) updateData['jobCategory'] = _jobCategory;
      if (profileUrl != null) updateData['profilePhotoUrl'] = profileUrl;
      if (idUrl != null) updateData['idImageUrl'] = idUrl;
      if (cvUrl != null) updateData['cvUrl'] = cvUrl;
      if (certificateUrl != null) {
        updateData['certificateUrl'] = certificateUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully! Admin approval required.'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildImagePicker(String label, File? file, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _pickAndCropImage(ImageSource.gallery, type),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF062D8A),
                foregroundColor: Colors.white,
              ),
              child: Text(file == null ? 'Upload' : 'Replace'),
            ),
            const SizedBox(width: 16),
            if (file != null)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(file, fit: BoxFit.cover),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDocumentUpload(String label, File? file, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => _pickAndCropImage(ImageSource.gallery, type),
              child: Text(file == null ? 'Upload' : 'Replace'),
            ),
            const SizedBox(width: 16),
            if (file != null)
              Text(
                file.path.split('/').last,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF062D8A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ghanaCardController,
                decoration: const InputDecoration(
                  labelText: 'Ghana Card Number',
                  hintText: 'GHA-123456789-0',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    _validateGhanaCard(value ?? '') ? null : 'Invalid format',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _dobController.text = DateFormat('yyyy-MM-dd').format(date);
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRegion,
                items: AppConstants.regionsAndCities.keys.map((region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                  _selectedRegion = value;
                  _selectedCity = null;
                }),
                decoration: const InputDecoration(
                  labelText: 'Region',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedRegion != null)
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  items: AppConstants.regionsAndCities[_selectedRegion]!
                      .map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCity = value),
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 16),
              _buildImagePicker('Profile Photo', _profilePhotoFile, 'profile'),
              _buildImagePicker('ID Card Photo', _idImageFile, 'id'),
              if (_jobCategory != null) ...[
                DropdownButtonFormField<String>(
                  value: _jobCategory,
                  items: AppConstants.jobCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _jobCategory = value),
                  decoration: const InputDecoration(
                    labelText: 'Job Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDocumentUpload('CV Document', _cvFile, 'cv'),
                _buildDocumentUpload(
                    'Professional Certificate', _certificateFile, 'certificate'),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCurrentUser ? _updateProfile : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF062D8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateGhanaCard(String idNumber) {
    RegExp idPattern = RegExp(r'^GHA-\d{9}-\d$');
    return idPattern.hasMatch(idNumber.trim());
  }
}