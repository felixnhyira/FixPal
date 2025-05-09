// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:fixpal/utils/constants.dart';

class JobPostingScreen extends StatefulWidget {
  final String? userId;

  const JobPostingScreen({super.key, this.userId});

  @override
  _JobPostingScreenState createState() => _JobPostingScreenState();
}

class _JobPostingScreenState extends State<JobPostingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

  String? _selectedCategory;
  String? _selectedRegion;
  String? _selectedCity;

  File? _imageFile;
  File? _videoFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadFile(File file, String folder) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('$folder/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading file: $e')));
      return null;
    }
  }

  Future<void> _postJob() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedRegion == null ||
        _selectedCity == null ||
        _deadlineController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    try {
      String? imageUrl;
      String? videoUrl;

      // Upload image if selected
      if (_imageFile != null) {
        imageUrl = await _uploadFile(_imageFile!, 'job_images');
      }

      // Upload video if selected
      if (_videoFile != null) {
        videoUrl = await _uploadFile(_videoFile!, 'job_videos');
      }

      // Save job posting to Firestore
      await FirebaseFirestore.instance.collection('jobs').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'region': _selectedRegion,
        'city': _selectedCity,
        'deadline': DateFormat('yyyy-MM-dd').parse(_deadlineController.text),
        'postedBy': widget.userId,
        'status': 'open',
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        'timestamp': FieldValue.serverTimestamp(), // Automatically adds server timestamp
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job posted successfully')));

      // Navigate back to the previous screen after posting
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error posting job: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
        backgroundColor: const Color(0xFF062D8A), // Primary blue color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Title Input
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Job Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              // Job Description Input
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Job Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              // Job Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: AppConstants.jobCategories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value; // No need for `as String?`
                  });
                },
                decoration: const InputDecoration(labelText: 'Job Category', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              // Region and City Dropdowns
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedRegion,
                      items: AppConstants.regionsAndCities.keys.map((region) {
                        return DropdownMenuItem(value: region, child: Text(region));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRegion = value; // No need for `as String?`
                          _selectedCity = null; // Reset city when region changes
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Region', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCity,
                      items: _selectedRegion != null
                          ? AppConstants.regionsAndCities[_selectedRegion]!.map((city) {
                              return DropdownMenuItem(value: city, child: Text(city));
                            }).toList()
                          : [],
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value; // No need for `as String?`
                        });
                      },
                      decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Deadline Picker
              TextField(
                controller: _deadlineController,
                readOnly: true,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(DateTime.now().year + 1),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _deadlineController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 20),

              // Media Upload Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF062D8A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Upload Image'),
                  ),
                  ElevatedButton(
                    onPressed: _pickVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF062D8A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Upload Video'),
                  ),
                ],
              ),

              // Preview Uploaded Files
              if (_imageFile != null)
                Image.file(
                  _imageFile!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              if (_videoFile != null)
                const Text('Video uploaded successfully', style: TextStyle(color: Colors.green)),

              const SizedBox(height: 20),

              // Post Job Button
              ElevatedButton(
                onPressed: _postJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF062D8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), // Consistent padding
                ),
                child: const Text('Post Job'), // Ensure 'child' is last
              ),
            ],
          ),
        ),
      ),
    );
  }
}