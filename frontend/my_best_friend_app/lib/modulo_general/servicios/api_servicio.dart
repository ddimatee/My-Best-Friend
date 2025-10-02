import '../../../services/api_service.dart';

// Servicio de autenticación/login OFFLINE (delegando al ApiService mock).
final ApiService _api = ApiService();

Future<String?> loginUsuario(String correo, String contrasenia) async {
  final resp = await _api.iniciarSesion(correo: correo, password: contrasenia);
  if (resp['success']) {
    final data = resp['data'];
    if (data is Map && data['token'] != null) return data['token'] as String; 
  }
  return null;
}
