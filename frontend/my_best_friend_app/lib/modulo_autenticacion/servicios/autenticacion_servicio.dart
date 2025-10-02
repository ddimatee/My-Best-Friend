import '../../../services/api_service.dart';

// Servicio de autenticación OFFLINE (simulación) para flujo de recuperación.
class AuthService {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final Map<String, String> _codes = {}; // email -> code temporal
  static final ApiService _api = ApiService();

  static Future<void> requestPasswordReset(String email) async {
    if (!_emailRegex.hasMatch(email.trim())) {
      throw Exception('Correo inválido');
    }
    // Simulamos existencia de usuario: si no existe devolvemos error similar al backend
    // Para simplificar, siempre creamos un usuario fantasma si no existe.
    try {
      final perfil = await _api.iniciarSesion(correo: email.trim(), password: 'dummy');
      if(!perfil['success']){
        // registramos usuario dummy para permitir flujo
        await _api.registrarUsuario(
          nombre: 'Usuario',
          apellido: 'Offline',
            correo: email.trim(),
          celular: '000000000',
          password: 'Temporal1',
        );
      }
    } catch (_) {}
    final code = _generarCodigo();
    _codes[email.trim().toLowerCase()] = code;
    // En modo offline no se envía correo; podrías imprimir en consola si deseas.
  }

  static Future<void> verifyResetCode(String email, String code) async {
    final stored = _codes[email.trim().toLowerCase()];
    if(stored == null || stored != code.trim()){
      throw Exception('Código inválido');
    }
  }

  static Future<void> resetPassword(String email, String code, String newPassword) async {
    if(!_isStrong(newPassword)) {
      throw Exception('Min 8 caracteres, una letra y un número');
    }
    await verifyResetCode(email, code);
    // No tenemos hash ni password real en este mock; simplemente invalidamos el código.
    _codes.remove(email.trim().toLowerCase());
  }

  static bool _isStrong(String value) {
    final v = value.trim();
    if (v.length < 8) return false;
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);
    final hasNumber = RegExp(r'[0-9]').hasMatch(v);
    return hasLetter && hasNumber;
  }

  static String _generarCodigo(){
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    return now.substring(now.length-6);
  }
}
