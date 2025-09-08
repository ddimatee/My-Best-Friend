import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> loginUsuario(String correo, String contrasenia) async {
  final url = Uri.parse('http://10.0.2.2:3000/api/usuarios/login'); // usa tu IP si estás en dispositivo físico

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'correo': correo,
        'contraseña': contrasenia,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      print('Error de login: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Excepción en login: $e');
    return null;
  }
}