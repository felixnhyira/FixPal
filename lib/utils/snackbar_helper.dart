import 'package:flutter/material.dart';

class SnackbarHelper {
  // Basic snackbar
  static void show(BuildContext context, String message) {
    _showCustomSnackbar(context, message: message);
  }

  // Success snackbar
  static void showSuccess(BuildContext context, String message) {
    _showCustomSnackbar(
      context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green.shade600,
    );
  }

  // Error snackbar
  static void showError(BuildContext context, String message) {
    _showCustomSnackbar(
      context,
      message: message,
      icon: Icons.error,
      backgroundColor: Colors.red.shade600,
    );
  }

  // Info snackbar
  static void showInfo(BuildContext context, String message) {
    _showCustomSnackbar(
      context,
      message: message,
      icon: Icons.info,
      backgroundColor: Colors.blue.shade600,
    );
  }

  // Warning snackbar
  static void showWarning(BuildContext context, String message) {
    _showCustomSnackbar(
      context,
      message: message,
      icon: Icons.warning,
      backgroundColor: Colors.orange.shade600,
    );
  }

  // Custom snackbar
  static void _showCustomSnackbar(
      BuildContext context, {
        required String message,
        IconData? icon,
        Color? backgroundColor,
        String? actionLabel,
        VoidCallback? onAction,
        Duration duration = const Duration(seconds: 3),
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor ?? Theme.of(context).snackBarTheme.backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
          label: actionLabel,
          onPressed: onAction ?? () {},
          textColor: Colors.white,
        )
            : null,
      ),
    );
  }

  // Dismiss all snackbars
  static void dismissAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}