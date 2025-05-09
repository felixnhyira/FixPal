import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixpal/main.dart';

void main() {
  // Initialize mock SharedPreferences before tests
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Verify Splash Screen is displayed on app launch', (WidgetTester tester) async {
    // Get the mock SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();
    
    // Build the app with the mock preferences (remove const)
    await tester.pumpWidget(FixPalApp(prefs: prefs));

    // Verify splash screen elements
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}