import 'package:fixpal/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Show SnackBar
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Navigate to a New Screen
  static void navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  // Replace Current Screen
  static void replaceScreen(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  // Format Date
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Check if User is Admin
  static bool isAdmin(String email) {
    return AppConstants.adminEmails.contains(email.toLowerCase());
  }

  // Get City List for a Region
  static List<String>? getCitiesForRegion(String region) {
    return AppConstants.regionsAndCities[region];
  }
}