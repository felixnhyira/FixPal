import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixpal/firebase_options.dart';
import 'package:fixpal/services/connectivity_monitor.dart';
import 'package:fixpal/screens/home_screen.dart';
import 'package:fixpal/screens/login_screen.dart';
import 'package:fixpal/screens/splash_screen.dart';
import 'package:fixpal/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize localization data
  await initializeDateFormatting(); // For default locale
  Intl.defaultLocale = 'en'; // Set default language

  try {
    // Initialize Firebase with options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
      
        
    );

    // Request necessary permissions
    await requestPermissions();

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Disables strict verification
      await FirebaseAuth.instance.setSettings(
    appVerificationDisabledForTesting: true, 
  );

    // Run the app with connectivity monitoring
    runApp(
      ConnectivityMonitor(
        child: FixPalApp(prefs: prefs),
      ),
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Initialization error: $e');
    }
    // Fallback to error app if initialization fails
    runApp(const ErrorApp());
  }
}

Future<void> requestPermissions() async {
  final permissions = await [
    Permission.phone,
    Permission.sms,
    Permission.camera,
    Permission.microphone,
    Permission.notification,
    Permission.location,
    Permission.storage,
  ].request();

  if (kDebugMode) {
    permissions.forEach((permission, status) {
      debugPrint('$permission: ${status.isGranted}');
    });
  }
}

class FixPalApp extends StatelessWidget {
  final SharedPreferences prefs;

  const FixPalApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixPal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppConstants.primaryBlue,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppConstants.secondaryPurple,
        ),
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: AppConstants.primaryBlue),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle unknown routes
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppConstants.errorRed,
                ),
                const SizedBox(height: 20),
                Text(
                  'Initialization Error',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppConstants.errorRed,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialize the app. Please try again later.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart the app
                    main();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}