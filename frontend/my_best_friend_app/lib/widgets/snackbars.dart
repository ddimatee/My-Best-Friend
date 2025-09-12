import 'package:flutter/material.dart';

SnackBar _buildSnackBar({
  required Color background,
  required IconData icon,
  required String message,
}) {
  return SnackBar(
    backgroundColor: background,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    duration: const Duration(seconds: 2),
    content: Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    _buildSnackBar(background: Colors.red, icon: Icons.error_outline, message: message),
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    _buildSnackBar(background: Colors.green, icon: Icons.check_circle_outline, message: message),
  );
}
