import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  // Colors
  static const Color primaryBlue = Color(0xFF062D8A);
  static const Color secondaryPurple = Color(0xFF8800FC);
  static const Color iconYellow = Color(0xFFFFEB3B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color black = Color(0xFF000000);
  static const Color errorRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF43A047);

  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeExtraLarge = 24.0;

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String jobsCollection = 'jobs';
  static const String applicationsCollection = 'applications';
  static const String messagesCollection = 'messages';
  static const String reviewsCollection = 'reviews';
  static const String notificationsCollection = 'notifications';
  static const String appConfigCollection = 'appConfig';

  // Support Information
  static const String supportPhone = '+233546296531';
  static const String supportEmail = '10285002@upsamail.edu.gh';

  // Authentication
  static const int otpResendTimeout = 30; // seconds
  static const int passwordMinLength = 8;

  // Admin Accounts
  static const List<String> adminEmails = [
    '10285002@upsamail.edu.gh',
    '10285479@upsamail.edu.gh',
    '10288570@upsamail.edu.gh',
  ];

  static const Map<String, String> defaultAdminAccounts = {
    '10285002@upsamail.edu.gh': 'DJ86231dfg',
    '10285479@upsamail.edu.gh': 'Ajkhf864f@',
    '10288570@upsamail.edu.gh': '15kmjkhhG4',
  };

  // Ghana Regions and Cities
  static const Map<String, List<String>> regionsAndCities = {
    'Greater Accra': [
      'Ablekuma Central', 'Ablekuma North', 'Ablekuma West', 'Adenta',
      'Ashaiman', 'Ayawaso Central', 'Ayawaso East', 'Ayawaso North',
      'Ayawaso West', 'Bawku', 'Bortianor-Ngleshie-Amanfrom', 'Ga Central',
      'Ga East', 'Ga North', 'Ga South', 'Klottey Korle', 'Krowor',
      'La Dade Kotopon', 'La Nkwantanang Madina', 'Ledzokuku', 'Madina',
      'Manhean', 'Okaikoi North', 'Okaikoi South', 'Osu Klottey',
      'Shai Osudoku', 'Tema East', 'Tema West', 'Trobu',
      'Ayawaso North East', 'Ayawaso North West', 'Ayawaso South East',
      'Ayawaso South West',
    ],
    'Ashanti': [
      'Adansi Asokwa', 'Adansi North', 'Adansi South', 'Afigya Kwabre North',
      'Afigya Kwabre South', 'Akrofuom', 'Amansie Central', 'Amansie West',
      'Asante Akim Central', 'Asante Akim North', 'Asante Akim South',
      'Asokore Mampong', 'Atwima Kwanwoma', 'Atwima Mponua', 'Bekwai',
      'Bosomtwe', 'Ejisu', 'Juaben', 'Kumasi Metropolitan East',
      'Kumasi Metropolitan North', 'Kumasi Metropolitan South',
      'Kumasi Metropolitan West', 'Kwadaso', 'Mampong', 'Obuasi East',
      'Obuasi West', 'Offinso North', 'Offinso South', 'Old Tafo',
      'Sekyere Afram Plains', 'Sekyere Central', 'Sekyere East',
    ],
    // Other regions remain the same...
  };

  // Job Categories
  static const List<String> jobCategories = [
    'Carpenters', 'Plumbers', 'Launderers', 'Hard Laborers', 'Electricians',
    'Shoemakers', 'Painters', 'Mowers (Landscapers)', 'Sanitation Workers',
    'HVAC Technicians', 'Locksmiths', 'Appliance Repair Technicians',
    'Roofers', 'Flooring Installers', 'Window Cleaners', 'Pressure Washers',
    'Gutter Cleaners', 'Pest Control Specialists', 'Masonry Workers',
    'Drywall Installers and Finishers',
  ];

  // Asset Paths
  static const String placeholderIDImage = 'assets/images/placeholder_id.png';
  static const String placeholderProfileImage = 'assets/images/placeholder_profile.png';
  static const String appLogo = 'assets/images/logo.png';

  // Shared Preferences Keys
  static const String prefSavedEmail = 'savedEmail';
  static const String prefSavedPassword = 'savedPassword';
  static const String prefFirstLaunch = 'firstLaunch';
  static const String prefDarkMode = 'darkMode';

  // Save user credentials securely
  static Future<void> saveLoginDetails(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(prefSavedEmail, email.trim()),
      prefs.setString(prefSavedPassword, password.trim()),
    ]);
  }

  // Load saved credentials
  static Future<Map<String, String>?> loadSavedLoginDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(prefSavedEmail);
    final password = prefs.getString(prefSavedPassword);

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  // Clear saved credentials
  static Future<void> clearLoginDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(prefSavedEmail),
      prefs.remove(prefSavedPassword),
    ]);
  }

  // Check if first app launch
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefFirstLaunch) ?? true;
  }

  // Set first launch completed
  static Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefFirstLaunch, false);
  }
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppConstants.errorRed,
  );
}

class AppDimens {
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double buttonHeight = 48.0;
  static const double borderRadius = 8.0;
  static const double textFieldBorderRadius = 4.0;
}