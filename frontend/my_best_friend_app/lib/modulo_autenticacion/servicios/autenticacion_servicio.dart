import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../services/api_service.dart';

// Servicio de autenticación real para recuperación de contraseña.
class AuthService {
	static final RegExp _phoneRegex = RegExp(r'^[0-9]{10}$');

	// Solicita el envío de un código por SMS al número de teléfono
	// Devuelve el correo del usuario para usarlo en pasos posteriores
	static Future<String> requestPasswordReset(String phone) async {
		final cleanPhone = phone.trim().replaceAll(RegExp(r'\D'), '');
		if (!_phoneRegex.hasMatch(cleanPhone)) {
			throw Exception('Número de teléfono inválido (debe tener 10 dígitos)');
		}
		final uri = Uri.parse('${ApiService.baseUrl}/usuarios/password/solicitar');
		final resp = await http.post(
			uri,
			headers: {'Content-Type': 'application/json'},
			body: jsonEncode({'celular': cleanPhone}),
		);
		if (resp.statusCode != 200) {
			final body = _safe(resp.body);
			throw Exception(body['error'] ?? body['message'] ?? 'Error solicitando código');
		}
		// Extraer el correo de la respuesta para usarlo en verificación y reset
		final body = _safe(resp.body);
		return body['correo'] ?? '';
	}

	static Future<void> verifyResetCode(String email, String code) async {
		if (code.trim().length != 6) throw Exception('Código debe tener 6 dígitos');
		final uri = Uri.parse('${ApiService.baseUrl}/usuarios/password/verificar');
		final resp = await http.post(
			uri,
			headers: {'Content-Type': 'application/json'},
			body: jsonEncode({'correo': email.trim(), 'code': code.trim()}),
		);
		if (resp.statusCode != 200) {
			final body = _safe(resp.body);
			throw Exception(body['error'] ?? body['message'] ?? 'Código inválido');
		}
	}

	static Future<void> resetPassword(String email, String code, String newPassword) async {
		if (!_isStrong(newPassword)) {
			throw Exception('Min 8 caracteres, una letra y un número');
		}
		// Verificar primero
		await verifyResetCode(email, code);
		final uri = Uri.parse('${ApiService.baseUrl}/usuarios/password/reset');
		final resp = await http.post(
			uri,
			headers: {'Content-Type': 'application/json'},
			body: jsonEncode({
				'correo': email.trim(),
				'code': code.trim(),
				'nuevaContraseña': newPassword,
			}),
		);
		if (resp.statusCode != 200) {
			final body = _safe(resp.body);
			throw Exception(body['error'] ?? body['message'] ?? 'Error al resetear');
		}
	}

	static bool _isStrong(String value) {
		final v = value.trim();
		if (v.length < 8) return false;
		final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);
		final hasNumber = RegExp(r'[0-9]').hasMatch(v);
		return hasLetter && hasNumber;
	}

	static Map<String, dynamic> _safe(String body) {
		try { return jsonDecode(body); } catch (_) { return {}; }
	}
}
