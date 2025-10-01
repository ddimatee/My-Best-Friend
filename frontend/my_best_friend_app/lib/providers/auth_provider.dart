import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mascotas_provider.dart';
import 'vacunas_provider.dart';
import 'peso_provider.dart';
import 'album_provider.dart';
import 'eventos_provider.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get errorMessage => _errorMessage;

  // Constructor
  AuthProvider() {
    _checkAuthStatus();
  }

  // Verificar si el usuario está autenticado
  Future<void> _checkAuthStatus() async {
    final token = await _apiService.getToken();
    if (token != null) {
      await obtenerPerfil();
      return;
    }
    // Intentar remember token
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getString('remember_token');
    final correo = prefs.getString('remember_correo');
    final password = prefs.getString('remember_password');
    if (remember != null && correo != null && password != null) {
      // Intentar login silencioso
      await iniciarSesion(correo: correo, password: password, recordar: true, silencioso: true);
    }
  }

  // Registrar usuario
  Future<bool> registrarUsuario({
    required String nombre,
    required String apellido,
    required String correo,
    required String celular,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.registrarUsuario(
        nombre: nombre,
        apellido: apellido,
        correo: correo,
        celular: celular,
        password: password,
      );

      if (result['success']) {
        _setLoading(false);
        return true;
      } else {
        _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }

  // Iniciar sesión
  Future<bool> iniciarSesion({
    required String correo,
    required String password,
    bool recordar = false,
    bool silencioso = false,
  }) async {
    _setLoading(true);
    if (!silencioso) _clearError();

    try {
      final result = await _apiService.iniciarSesion(
        correo: correo,
        password: password,
        recordar: recordar,
      );

      if (result['success']) {
        _user = result['data']['usuario'];
        _isAuthenticated = true;
        // Intentar reprogramar recordatorios (necesitamos context externo normalmente, se puede diferir)
        if (recordar) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('remember_correo', correo);
          await prefs.setString('remember_password', password); // Nota: en producción usar cifrado
        }
        _setLoading(false);
        return true;
      } else {
        if (!silencioso) _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      if (!silencioso) _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }

  // Obtener perfil del usuario
  Future<bool> obtenerPerfil() async {
    try {
      final result = await _apiService.obtenerPerfil();

      if (result['success']) {
        _user = result['data'];
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _cerrarSesionLocal();
        return false;
      }
    } catch (e) {
      _cerrarSesionLocal();
      return false;
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion({required BuildContext context}) async {
    await _apiService.cerrarSesion();
    _cerrarSesionLocal(context: context);
  }

  // Cerrar sesión local
  void _cerrarSesionLocal({BuildContext? context}) {
    _isAuthenticated = false;
    _user = null;
    // Limpiar datos remember
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('remember_correo');
      prefs.remove('remember_password');
      // No borro remember_token para posible auditoría, pero se podría
    });
    _clearError();
    notifyListeners();
    // Limpiar otros providers para evitar fugas entre usuarios
    if (context != null) {
      try { (context as dynamic).read<MascotasProvider>().clear(); } catch (_) {}
      try { (context as dynamic).read<VacunasProvider>().clear(); } catch (_) {}
      try { (context as dynamic).read<PesoProvider>().clear(); } catch (_) {}
      try { (context as dynamic).read<AlbumProvider>().clear(); } catch (_) {}
      try { (context as dynamic).read<EventosProvider>().clear(); } catch (_) {}
    }
  }

  // Manejo central de 401: llamado por capas superiores cuando ApiService detecta unauthorized
  Future<void> handleUnauthorized({BuildContext? context}) async {
    if (!_isAuthenticated) return; // ya deslogueado
    await _apiService.removeToken();
    _cerrarSesionLocal(context: context);
  }

  // Métodos privados para manejar el estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Actualizar campos básicos del perfil localmente (sin llamar backend)
  void updateUserProfile({String? nombre, String? apellido, String? correo, String? celular}) {
    if (_user == null) return;
    if (nombre != null) _user!['nombre'] = nombre;
    if (apellido != null) _user!['apellido'] = apellido;
    if (correo != null) _user!['correo'] = correo;
    if (celular != null) _user!['celular'] = celular;
    notifyListeners();
  }
}