import 'dart:convert';
import 'package:http/http.dart' as http;

// Servicio de API para autenticación/login. Mover aquí futuras llamadas.
Future<String?> loginUsuario(String correo, String contrasenia) async {
  final url = Uri.parse('http://10.0.2.2:3000/api/usuarios/login');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'correo': correo, 'contraseña': contrasenia}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'] as String?;
    } else {
      // Puedes mapear códigos de error específicos aquí
      return null;
    }
  } catch (_) {
    return null;
  }
}
