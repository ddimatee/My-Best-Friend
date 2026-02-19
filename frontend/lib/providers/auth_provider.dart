import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mascotas_provider.dart';
import 'vacunas_provider.dart';
import 'peso_provider.dart';
import 'album_provider.dart';
import 'eventos_provider.dart';
import '../services/notification_service.dart';
import '../services/push_service.dart';
import 'recordatorios_provider.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _errorMessage;
  bool _mantenerSesion = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get mantenerSesion => _mantenerSesion;

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
    _mantenerSesion = prefs.getBool('keep_session') ?? false;
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
    BuildContext? contextForProviders,
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
        // Siempre cancelar notificaciones del usuario anterior
        try { await NotificationService().cancelAll(); } catch (_) {}
        // Se limpia primero providers para evitar mostrar datos rezagados
        if (contextForProviders != null) {
          try { (contextForProviders as dynamic).read<MascotasProvider>().clear(); } catch (_) {}
          try { (contextForProviders as dynamic).read<VacunasProvider>().clear(); } catch (_) {}
          try { (contextForProviders as dynamic).read<PesoProvider>().clear(); } catch (_) {}
          try { (contextForProviders as dynamic).read<AlbumProvider>().clear(); } catch (_) {}
          try { (contextForProviders as dynamic).read<EventosProvider>().clear(); } catch (_) {}
        }
        _user = result['data']['usuario'];
        _isAuthenticated = true;
        // Intentar inicializar push y registrar token FCM
        try {
          await PushService().init();
          await PushService().obtenerYRegistrarTokenBackend();
        } catch (_) {}
        // Sincronizar recordatorios del calendario con backend (best-effort)
        if (contextForProviders != null) {
          final uid = _user?['_id']?.toString();
          if (uid != null && uid.isNotEmpty) {
            try { (contextForProviders as dynamic).read<RecordatoriosProvider>().sincronizar(userId: uid); } catch (_) {}
          }
        }
        // Intentar reprogramar recordatorios (necesitamos context externo normalmente, se puede diferir)
        if (recordar) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('remember_correo', correo);
          await prefs.setString('remember_password', password); // Nota: en producción usar cifrado
        }
        if (_mantenerSesion) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('remember_correo', correo);
          await prefs.setString('remember_password', password);
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
        _user = result['data']['usuario'];
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
    try { await NotificationService().cancelAll(); } catch (_) {}
    // Eliminar token FCM del backend (best-effort)
    try {
      // No almacenamos el token local aún; podrías guardarlo en SharedPreferences si quieres eliminarlo con precisión
    } catch (_) {}
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
      if (!_mantenerSesion) {
        prefs.remove('keep_session');
      }
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

  Future<void> setMantenerSesion(bool value) async {
    _mantenerSesion = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keep_session', value);
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

  void mergeUserData(Map<String,dynamic> data) {
    if (_user == null) {
      _user = data;
    } else {
      _user!.addAll(data);
    }
    notifyListeners();
  }
}