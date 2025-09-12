import 'dart:async';

class AuthService {
  // Simulated backend for demo purposes
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static Future<void> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!_emailRegex.hasMatch(email.trim())) {
      throw Exception('Correo inválido');
    }
    // In a real app, send a code to user's email here.
  }

  static Future<void> verifyResetCode(String email, String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (code.trim() != '123456') {
      throw Exception('Código incorrecto');
    }
  }

  static Future<void> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    await verifyResetCode(email, code); // Ensure code is valid
    await Future.delayed(const Duration(milliseconds: 300));
    if (!_isStrong(newPassword)) {
      throw Exception('La contraseña debe tener al menos 8 caracteres, una letra y un número');
    }
    // In a real app, call backend to persist the new password
  }

  static bool _isStrong(String value) {
    final v = value.trim();
    if (v.length < 8) return false;
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);
    final hasNumber = RegExp(r'[0-9]').hasMatch(v);
    return hasLetter && hasNumber;
  }
}
