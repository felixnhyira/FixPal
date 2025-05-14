import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:fixpal/screens/login_screen.dart';
import 'package:fixpal/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fixpal/utils/snackbar_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ghanaCardController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // Form state
  String? _selectedRole;
  String? _selectedRegion;
  String? _selectedCity;
  String? _jobCategory;
  int _currentStep = 0;

  // Password validation
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSymbol = false;
  bool _isPasswordValid = false;

  // File uploads (now optional)
  File? _idImageFile;
  File? _profilePhotoFile;
  File? _cvFile;
  File? _certificateFile;

  // Loading state
  bool _isRegistering = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    _ghanaCardController.dispose();
    super.dispose();
  }

  bool _validateGhanaCard(String idNumber) {
    RegExp idPattern = RegExp(r'^GHA-\d{9}-\d$');
    return idPattern.hasMatch(idNumber.trim());
  }

  bool _validatePhoneNumber(String phoneNumber) {
    RegExp phonePattern = RegExp(r'^(0[2356789])\d{8}$');
    return phonePattern.hasMatch(phoneNumber.trim());
  }

  bool _validateEmail(String email) {
    RegExp emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailPattern.hasMatch(email.trim());
  }

  void _validatePassword(String password) {
    setState(() {
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSymbol = password.contains(RegExp(r'[!@#\$\%\^\&\*(),.?":{}|<>]'));
      _isPasswordValid = password.length >= 8 &&
          _hasUppercase &&
          _hasLowercase &&
          _hasNumber &&
          _hasSymbol;
    });
  }

  Future<void> _pickAndCropImage(ImageSource source, String type) async {
    try {
      // Check and request storage permission
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        if (result.isDenied || result.isPermanentlyDenied) {
          SnackbarHelper.showError(context, 'Storage permission is required to select images');
          return;
        }
      }

      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: type == 'profile'
            ? const CropAspectRatio(ratioX: 1, ratioY: 1)
            : null,
        compressQuality: 70,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: type == 'profile'
                ? CropAspectRatioPreset.square
                : CropAspectRatioPreset.original,
            lockAspectRatio: type == 'profile',
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          if (type == 'id') {
            _idImageFile = File(croppedFile.path);
          } else if (type == 'profile') {
            _profilePhotoFile = File(croppedFile.path);
          } else if (type == 'certificate') {
            _certificateFile = File(croppedFile.path);
          }
        });
      }
    } catch (e) {
      SnackbarHelper.showError(context, 'Failed to pick/crop image: $e');
    }
  }

  Future<bool> _isEmailRegistered(String email) async {
    try {
      final emailQuery = await _firestore.collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return emailQuery.docs.isNotEmpty;
    } catch (e) {
      SnackbarHelper.showError(context, 'Error checking email');
      return false;
    }
  }

  Future<String?> _uploadFile(File? file, String path) async {
    if (file == null) return null;
    try {
      final ref = _storage.ref().child('user_uploads/$path');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      SnackbarHelper.showError(context, 'File upload failed: $e');
      return null;
    }
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      SnackbarHelper.showWarning(context, 'Please fix the errors in the form');
      return;
    }
    final emailExists = await _isEmailRegistered(_emailController.text.trim());
    if (emailExists) {
      SnackbarHelper.showError(context, 'Email already registered');
      return;
    }
    setState(() => _isRegistering = true);
    try {
      // Create user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Upload files if they exist (all optional now)
      final profileUrl = await _uploadFile(_profilePhotoFile, 'profile_${userCredential.user!.uid}');
      final idUrl = await _uploadFile(_idImageFile, 'id_${userCredential.user!.uid}');
      final cvUrl = await _uploadFile(_cvFile, 'cv_${userCredential.user!.uid}');
      final certificateUrl = await _uploadFile(_certificateFile, 'certificate_${userCredential.user!.uid}');

          // Save user data
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'userId': userCredential.user!.uid,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': '+233${_phoneController.text.substring(1)}',
        'email': _emailController.text.trim(),
        'ghanaCardNumber': _ghanaCardController.text.trim(),
        'role': _selectedRole,
        'region': _selectedRegion,
        'city': _selectedCity,
        'jobCategory': _jobCategory,
        'profilePhotoUrl': profileUrl,
        'idImageUrl': idUrl,
        'cvUrl': cvUrl,
        'certificateUrl': certificateUrl,
        'dob': _dobController.text,
        'phoneVerified': false,
        'emailVerified': false,
        'verificationStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      SnackbarHelper.showSuccess(context, 'Registration successful!');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
    SnackbarHelper.showError(context, 'Registration failed: $e');
    } finally {
    if (mounted) setState(() => _isRegistering = false);
    }
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 30,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: _currentStep >= index
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget _buildOutlinedFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
    bool readOnly = false,
    VoidCallback? onTap,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorMaxLines: 2,
      ),
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
    );
  }

  Widget _buildStepHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPersonalDetailsStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Personal Information'),
          Row(
            children: [
              Expanded(
                child: _buildOutlinedFormField(
                  controller: _firstNameController,
                  labelText: 'First Name',
                  icon: Icons.person,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOutlinedFormField(
                  controller: _lastNameController,
                  labelText: 'Last Name',
                  icon: Icons.person,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildOutlinedFormField(
            controller: _ghanaCardController,
            labelText: 'Ghana Card Number',
            icon: Icons.credit_card,
            hintText: 'GHA-123456789-0',
            validator: (value) => _validateGhanaCard(value ?? '')
                ? null
                : 'Invalid format (e.g., GHA-123456789-0)',
          ),
          const SizedBox(height: 16),
          _buildOutlinedFormField(
            controller: _dobController,
            labelText: 'Date of Birth',
            icon: Icons.calendar_today,
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 6570)),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Theme.of(context).primaryColor,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() {
                  _dobController.text = DateFormat('yyyy-MM-dd').format(date);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Contact Information'),
          _buildOutlinedFormField(
            controller: _phoneController,
            labelText: 'Phone Number',
            icon: Icons.phone,
            hintText: '0234567890',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Phone number is required';
              if (!_validatePhoneNumber(value)) {
                return 'Enter a valid Ghanaian number\n(Example: 0234567890)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildOutlinedFormField(
            controller: _emailController,
            labelText: 'Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required';
              if (!_validateEmail(value)) {
                return 'Enter a valid email\n(Example: user@example.com)';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Account Security'),
          _buildOutlinedFormField(
            controller: _passwordController,
            labelText: 'Password',
            icon: Icons.lock,
            obscureText: true,
            onChanged: _validatePassword,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a password';
              if (!_isPasswordValid) return 'Password does not meet requirements';
              return null;
            },
          ),
          const SizedBox(height: 16),
          PasswordStrengthIndicator(
            hasUppercase: _hasUppercase,
            hasLowercase: _hasLowercase,
            hasNumber: _hasNumber,
            hasSymbol: _hasSymbol,
            isValidLength: _passwordController.text.length >= 8,
          ),
          const SizedBox(height: 16),
          _buildOutlinedFormField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            icon: Icons.lock,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please confirm your password';
              if (value != _passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Password Requirements:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildPasswordRequirement('At least 8 characters', _passwordController.text.length >= 8),
          _buildPasswordRequirement('1 uppercase letter', _hasUppercase),
          _buildPasswordRequirement('1 lowercase letter', _hasLowercase),
          _buildPasswordRequirement('1 number', _hasNumber),
          _buildPasswordRequirement('1 special character', _hasSymbol),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle,
            color: isMet ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Profile Completion'),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: InputDecoration(
              labelText: 'I am registering as a',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: ['Freelancer', 'Client'].map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(role),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedRole = value),
            validator: (value) => value == null ? 'Please select a role' : null,
          ),
          if (_selectedRole != null) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRegion,
              decoration: InputDecoration(
                labelText: 'Region',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
              validator: (value) => value == null ? 'Please select a region' : null,
            ),
            if (_selectedRegion != null) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: AppConstants.regionsAndCities[_selectedRegion]!.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCity = value),
                validator: (value) => value == null ? 'Please select a city' : null,
              ),
            ],
            if (_selectedRole == 'Freelancer') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _jobCategory,
                decoration: InputDecoration(
                  labelText: 'Job Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: AppConstants.jobCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _jobCategory = value),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
            ],
          ],
          const SizedBox(height: 24),
          const Text('Profile Photo (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Upload Profile Photo'),
                  onPressed: () => _pickAndCropImage(ImageSource.gallery, 'profile'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
              if (_profilePhotoFile != null) ...[
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 30,
                  backgroundImage: FileImage(_profilePhotoFile!),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          const Text('ID Card Photo (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.credit_card),
                  label: const Text('Upload ID Photo'),
                  onPressed: () => _pickAndCropImage(ImageSource.gallery, 'id'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
              if (_idImageFile != null) ...[
                const SizedBox(width: 16),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(_idImageFile!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Help'),
                content: const Text('Contact support@fixpal.com for assistance.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStepIndicator(),
            const SizedBox(height: 24),
            if (_currentStep == 0) _buildPersonalDetailsStep(),
            if (_currentStep == 1) _buildContactInfoStep(),
            if (_currentStep == 2) _buildPasswordStep(),
            if (_currentStep == 3) _buildProfileCompletionStep(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                if (_currentStep < 3)
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _currentStep++);
                      } else {
                        SnackbarHelper.showWarning(context, 'Please fix all errors before continuing');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Next'),
                  ),
                if (_currentStep == 3)
                  ElevatedButton(
                    onPressed: _isRegistering ? null : _registerUser,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isRegistering
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Complete Registration'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSymbol;
  final bool isValidLength;

  const PasswordStrengthIndicator({
    super.key,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSymbol,
    required this.isValidLength,
  });

  @override
  Widget build(BuildContext context) {
    final totalRequirements = 5;
    final metRequirements = [
      hasUppercase,
      hasLowercase,
      hasNumber,
      hasSymbol,
      isValidLength
    ].where((met) => met).length;
    return Column(
      children: [
        LinearProgressIndicator(
          value: metRequirements / totalRequirements,
          backgroundColor: Colors.grey[200],
          color: metRequirements == totalRequirements ? Colors.green : Colors.orange,
          minHeight: 6,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$metRequirements/$totalRequirements requirements met',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}