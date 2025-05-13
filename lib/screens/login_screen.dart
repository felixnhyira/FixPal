import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fixpal/screens/home_screen.dart';
import 'package:fixpal/screens/register_screen.dart';
import 'package:fixpal/screens/password_recovery_screen.dart';
import 'package:fixpal/screens/terms_and_conditions_screen.dart';
import 'package:fixpal/screens/privacy_policy_screen.dart';
import 'package:fixpal/utils/constants.dart';
import 'package:fixpal/widgets/gradient_app_bar.dart';
import 'package:fixpal/widgets/auth_text_field.dart';
import 'package:fixpal/utils/snackbar_helper.dart'; // Ensure this import is correct

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _saveLoginDetails = false;
  bool _showPassword = false;
  bool _termsAccepted = false;
  bool _isLoading = false;
  bool _isPhoneLogin = false;
  bool _codeSent = false;
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_emailFocusNode.canRequestFocus) {
        FocusScope.of(context).requestFocus(_emailFocusNode);
      }
    });
  }

  Future<void> _initPrefs() async {
    final savedEmailOrPhone = await _storage.read(key: 'emailOrPhone');
    final savedPassword = await _storage.read(key: 'password');
    if (savedEmailOrPhone != null && savedPassword != null) {
      setState(() {
        _emailOrPhoneController.text = savedEmailOrPhone;
        _passwordController.text = savedPassword;
        _saveLoginDetails = true;
        _isPhoneLogin = _isNumeric(savedEmailOrPhone);
      });
    }
  }

  bool _isNumeric(String str) =>
      str.isNotEmpty && RegExp(r'^[0-9]+$').hasMatch(str);

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      SnackbarHelper.showError(
          context, 'Please accept the terms and conditions and privacy policy');
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential;
      if (_isPhoneLogin) {
        final phoneNumber = _emailOrPhoneController.text.trim();
        if (!phoneNumber.startsWith('+')) {
          _emailOrPhoneController.text =
          '+233${phoneNumber.substring(phoneNumber.startsWith('0') ? 1 : 0)}';
        }
        userCredential =
        await _signInWithPhoneNumber(_emailOrPhoneController.text.trim());
      } else {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailOrPhoneController.text.trim(),
          password: _passwordController.text.trim(),
        );


      }

      if (_saveLoginDetails) {
        await _storage.write(
            key: 'emailOrPhone', value: _emailOrPhoneController.text.trim());
        await _storage.write(
            key: 'password', value: _passwordController.text.trim());
      } else {
        await _storage.delete(key: 'emailOrPhone');
        await _storage.delete(key: 'password');
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      SnackbarHelper.showError(
          context, 'An unexpected error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<UserCredential> _signInWithPhoneNumber(String phoneNumber) async {
    final completer = Completer<UserCredential>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        final result = await _auth.signInWithCredential(credential);
        completer.complete(result);
      },
      verificationFailed: (e) {
        SnackbarHelper.showError(context, e.message ?? 'Verification failed');
        completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        if (mounted) {
          setState(() => _codeSent = true);
        }
        _promptSmsCode(context, verificationId);
        completer.completeError(Exception("SMS code required"));
      },
      codeAutoRetrievalTimeout: (id) {
        _verificationId = id;
      },
    );
    return completer.future;
  }

  void _promptSmsCode(BuildContext context, String verificationId) {
    final smsCodeController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter SMS Code"),
        content: TextField(
          controller: smsCodeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "6-digit code"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final credential = PhoneAuthProvider.credential(
                  verificationId: verificationId,
                  smsCode: smsCodeController.text.trim(),
                );
                final result = await _auth.signInWithCredential(credential);
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                  );
                }
              } catch (e) {
                SnackbarHelper.showError(context, "Invalid or expired code");
              }
            },
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }

  void _handleAuthError(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'invalid-email':
        errorMessage = 'Please enter a valid email address';
        break;
      case 'invalid-phone-number':
        errorMessage = 'Please enter a valid phone number with country code';
        break;
      case 'user-disabled':
        errorMessage = 'This account has been disabled. Contact support.';
        break;
      case 'user-not-found':
        errorMessage = 'No account found with these credentials';
        break;
      case 'wrong-password':
        errorMessage = 'Incorrect password. Please try again.';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many attempts. Try again later.';
        break;
      default:
        errorMessage = 'Login failed: ${e.message}';
    }
    SnackbarHelper.showError(context, errorMessage);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      SnackbarHelper.showError(context, 'Could not launch the requested app');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Login'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),
              Hero(
                tag: 'app-logo',
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.handyman,
                      size: 100,
                      color: AppConstants.primaryBlue),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'FixPal',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Trusted Freelance Service Provider',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              AuthTextField(
                controller: _emailOrPhoneController,
                focusNode: _emailFocusNode,
                labelText: _isPhoneLogin ? 'Phone Number' : 'Email',
                hintText:
                _isPhoneLogin ? '+233XXXXXXXXX' : 'your@email.com',
                prefixIcon: _isPhoneLogin ? Icons.phone : Icons.email,
                keyboardType: _isPhoneLogin
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context)
                    .requestFocus(_passwordFocusNode),
                inputFormatters: _isPhoneLogin
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your ${_isPhoneLogin ? 'phone number' : 'email'}';
                  }
                  if (_isPhoneLogin &&
                      !RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  if (!_isPhoneLogin &&
                      !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(_isPhoneLogin ? Icons.email : Icons.phone),
                  onPressed: () {
                    final currentInput =
                    _emailOrPhoneController.text.trim();
                    setState(() {
                      _isPhoneLogin = !_isPhoneLogin;
                      if ((_isPhoneLogin && !_isNumeric(currentInput)) ||
                          (!_isPhoneLogin && _isNumeric(currentInput))) {
                        _emailOrPhoneController.clear();
                      }
                    });
                  },
                  tooltip: _isPhoneLogin
                      ? 'Use email instead'
                      : 'Use phone instead',
                ),
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icons.lock,
                obscureText: !_showPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _loginUser(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _saveLoginDetails,
                        onChanged: (value) =>
                            setState(() => _saveLoginDetails = value ?? false),
                        materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                      ),
                      const Text('Remember me'),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PasswordRecoveryScreen()),
                    ),
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _termsAccepted,
                    onChanged: (value) =>
                        setState(() => _termsAccepted = value ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const TermsAndConditionsScreen()),
                              ),
                              child: const Text(
                                'Terms',
                                style: TextStyle(
                                  color: AppConstants.primaryBlue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const PrivacyPolicyScreen()),
                              ),
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: AppConstants.primaryBlue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.primaryBlue,
                        AppConstants.secondaryPurple,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'LOG IN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text('Sign up'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Text(
                    'Need help? Contact our support team',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.phone,
                            color: AppConstants.primaryBlue),
                        onPressed: () =>
                            _launchUrl('tel:${AppConstants.supportPhone}'),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: const Icon(Icons.email,
                            color: AppConstants.primaryBlue),
                        onPressed: () =>
                            _launchUrl('mailto:${AppConstants.supportEmail}'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}