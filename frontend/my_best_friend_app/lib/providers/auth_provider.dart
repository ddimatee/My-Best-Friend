import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

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
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.iniciarSesion(
        correo: correo,
        password: password,
      );

      if (result['success']) {
        _user = result['data']['usuario'];
        _isAuthenticated = true;
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
  Future<void> cerrarSesion() async {
    await _apiService.cerrarSesion();
    _cerrarSesionLocal();
  }

  // Cerrar sesión local
  void _cerrarSesionLocal() {
    _isAuthenticated = false;
    _user = null;
    _clearError();
    notifyListeners();
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
}