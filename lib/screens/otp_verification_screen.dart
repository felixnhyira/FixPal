import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final Function(String verificationId)? onCodeSent;
  final VoidCallback onVerified;
  final bool allowAutoNavigate;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.onCodeSent,
    required this.onVerified,
    this.allowAutoNavigate = true,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isResendDisabled = true;
  bool _otpSent = false;
  bool _verificationComplete = false;
  String? _verificationId;
  int _countdown = 30;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkCachedVerification();
  }

  Future<void> _checkCachedVerification() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedVerified = prefs.getBool('${widget.phoneNumber}_verified') ?? false;
    if (cachedVerified && mounted) {
      _handleVerificationSuccess();
    }
  }

  Future<void> _sendOTP() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: _handleVerificationSuccess,
        verificationFailed: _handleVerificationFailed,
        codeSent: _handleCodeSent,
        codeAutoRetrievalTimeout: (verificationId) {
          if (mounted) {
            setState(() => _verificationId = verificationId);
          }
        },
        timeout: const Duration(seconds: 120),
      );
    } catch (e) {
      _handleVerificationFailed(FirebaseAuthException(
        code: 'send_otp_failed',
        message: e.toString(),
      ));
    }
  }

  void _handleVerificationSuccess([AuthCredential? credential]) async {
    if (_verificationComplete) return;
    
    final auth = FirebaseAuth.instance;
    if (credential != null) {
      await auth.signInWithCredential(credential);
    }

    if (mounted) {
      setState(() {
        _verificationComplete = true;
        _isVerifying = false;
      });

      // Cache verification state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${widget.phoneNumber}_verified', true);

      // Execute callback
      widget.onVerified();

      // Auto-navigate if enabled
      if (widget.allowAutoNavigate) {
        Navigator.maybePop(context, true);
      }
    }
  }

  void _handleVerificationFailed(FirebaseAuthException exception) {
    if (mounted) {
      setState(() {
        _isVerifying = false;
        _otpSent = false;
        _errorMessage = exception.message ?? 'Verification failed';
      });
    }
  }

  void _handleCodeSent(String verificationId, int? resendToken) {
    if (mounted) {
      setState(() {
        _verificationId = verificationId;
        _otpSent = true;
        _isVerifying = false;
      });
      _startCountdown();
      widget.onCodeSent?.call(verificationId);
    }
  }

  void _startCountdown() {
    setState(() {
      _isResendDisabled = true;
      _countdown = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        if (mounted) {
          setState(() => _isResendDisabled = false);
        }
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      setState(() => _errorMessage = 'Please enter a valid 6-digit code');
      return;
    }

    if (_verificationId == null) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      _handleVerificationSuccess(credential);
    } on FirebaseAuthException catch (e) {
      _handleVerificationFailed(e);
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isResendDisabled = true;
      _countdown = 30;
      _errorMessage = null;
    });

    _startCountdown();
    await _sendOTP();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
        actions: [
          if (_verificationComplete)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.verified, color: Colors.green),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Text(
              _otpSent
                  ? 'Enter the 6-digit code sent to ${widget.phoneNumber}'
                  : 'We will send a verification code to ${widget.phoneNumber}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),

            // Error Message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),

            // OTP Input (only shown after code is sent)
            if (_otpSent) ...[
              PinInputTextField(
                pinLength: 6,
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: BoxLooseDecoration(
                  strokeColorBuilder: PinListenColorBuilder(
                    Colors.grey,
                    Theme.of(context).primaryColor,
                  ),
                  bgColorBuilder: FixedColorBuilder(Colors.transparent),
                  strokeWidth: 2,
                  gapSpace: 12,
                ),
                onSubmit: (pin) => _verifyOTP(),
              ),
              const SizedBox(height: 20),
            ],

            // Action Buttons
            if (!_verificationComplete) ...[
              ElevatedButton(
                onPressed: _isVerifying
                    ? null
                    : _otpSent ? _verifyOTP : _sendOTP,
                child: _isVerifying
                    ? const CircularProgressIndicator()
                    : Text(_otpSent ? 'Verify Code' : 'Send Verification Code'),
              ),
              const SizedBox(height: 16),
              if (_otpSent)
                TextButton(
                  onPressed: _isResendDisabled ? null : _resendOTP,
                  child: Text(
                    _isResendDisabled
                        ? 'Resend code in $_countdown seconds'
                        : 'Resend Verification Code',
                  ),
                ),
            ],

            // Success State
            if (_verificationComplete) ...[
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              Text(
                'Phone number verified successfully!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (!widget.allowAutoNavigate)
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Continue'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}