import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConnectivitySnackbar {
  static void show({
    required BuildContext context,
    required bool hasConnection,
    VoidCallback? onRetry, // Optional: Manual retry callback
    bool autoRetry = false, // Enable auto-retry? (Default: false)
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Hide previous snackbar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Auto-retry logic (if enabled)
    if (!hasConnection && autoRetry && onRetry != null) {
      Future.delayed(const Duration(seconds: 5), () {
        if (!hasConnection) onRetry.call(); // Retry after 5 seconds
      });
    }

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 5), // Matches auto-retry delay
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasConnection
                ? Color.fromRGBO(
                    colorScheme.primary.red,
                    colorScheme.primary.green,
                    colorScheme.primary.blue,
                    0.9,
                  )
                : Color.fromRGBO(
                    colorScheme.error.red,
                    colorScheme.error.green,
                    colorScheme.error.blue,
                    0.9,
                  ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                hasConnection ? 'assets/wifi_on.svg' : 'assets/wifi_off.svg',
                width: 24,
                colorFilter: ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasConnection ? 'Back online!' : 'No internet connection',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              if (!hasConnection && onRetry != null) // Show retry button if offline
                TextButton(
                  child: const Text(
                    'RETRY',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    onRetry(); // Trigger manual retry
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}