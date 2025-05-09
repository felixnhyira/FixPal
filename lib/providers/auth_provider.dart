import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw PlatformException(code: 'ERROR_USER_NOT_FOUND', message: 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw PlatformException(code: 'ERROR_WRONG_PASSWORD', message: 'Wrong password provided.');
      }
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw PlatformException(code: 'ERROR_WEAK_PASSWORD', message: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw PlatformException(code: 'ERROR_EMAIL_ALREADY_IN_USE', message: 'The account already exists for that email.');
      }
      rethrow;
    }
  }

  // Send OTP for phone verification
  Future<void> sendOTP(String phoneNumber, Function(PhoneAuthCredential) verificationCompleted,
      Function(FirebaseAuthException) verificationFailed, Function(String, int?) codeSent) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Sign out the user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}