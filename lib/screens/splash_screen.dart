import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixpal/screens/home_screen.dart';
import 'package:fixpal/screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late SharedPreferences _prefs;
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _textDepthAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _bounceAnimation = Tween<double>(begin: -500, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
    );

    _textDepthAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    _initPrefsAndCheckAuth();
  }

  /// Initialize SharedPreferences and check for saved credentials
  Future<void> _initPrefsAndCheckAuth() async {
    _prefs = await SharedPreferences.getInstance();
    String? savedEmail = _prefs.getString('email');
    String? savedPassword = _prefs.getString('password');

    if (savedEmail != null && savedPassword != null) {
      await _autoLogin(savedEmail, savedPassword);
    } else {
      _navigateToScreen(const LoginScreen());
    }
  }

  /// Attempt auto-login with saved credentials
  Future<void> _autoLogin(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          _navigateToScreen(const HomeScreen());
        } else {
          await _clearSavedCredentials();
          _navigateToScreen(const LoginScreen());
        }
      }
    } catch (e) {
      await _clearSavedCredentials();
      _navigateToScreen(const LoginScreen());
    }
  }

  /// Clear saved credentials
  Future<void> _clearSavedCredentials() async {
    await _prefs.remove('email');
    await _prefs.remove('password');
  }

  /// Navigate to a new screen after animation completes
  void _navigateToScreen(Widget screen) {
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF062D8A), Color(0xFF8800FC)], // Blue-Purple gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(0, _bounceAnimation.value),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Transform.scale(
                    scale: _textDepthAnimation.value,
                    child: Text(
                      'FixPal',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
