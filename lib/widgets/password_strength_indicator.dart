import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSymbol;
  final bool isValidLength;
  final int minLength;

  const PasswordStrengthIndicator({
    super.key,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSymbol,
    required this.isValidLength,
    this.minLength = 8,
  });

  @override
  Widget build(BuildContext context) {
    final totalCriteria = 5;
    final metCriteria = [
      hasUppercase,
      hasLowercase,
      hasNumber,
      hasSymbol,
      isValidLength,
    ].where((met) => met).length;

    final strength = metCriteria / totalCriteria;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password Strength:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              _getStrengthText(strength),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getStrengthColor(strength),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: strength,
          backgroundColor: Colors.grey[200],
          color: _getStrengthColor(strength),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequirementRow(
              'At least $minLength characters',
              isValidLength,
            ),
            _buildRequirementRow('1 uppercase letter', hasUppercase),
            _buildRequirementRow('1 lowercase letter', hasLowercase),
            _buildRequirementRow('1 number', hasNumber),
            _buildRequirementRow('1 special character', hasSymbol),
          ],
        ),
      ],
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle,
            size: 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _getStrengthText(double strength) {
    if (strength >= 0.8) return 'Strong';
    if (strength >= 0.6) return 'Good';
    if (strength >= 0.4) return 'Fair';
    return 'Weak';
  }

  Color _getStrengthColor(double strength) {
    if (strength >= 0.8) return Colors.green;
    if (strength >= 0.6) return Colors.lightGreen;
    if (strength >= 0.4) return Colors.orange;
    return Colors.red;
  }
}