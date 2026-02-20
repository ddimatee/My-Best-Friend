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
  bool _authBootstrapDone = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get mantenerSesion => _mantenerSesion;
  bool get authBootstrapDone => _authBootstrapDone;

  // Constructor
  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _logRememberState(String tag) async {
    final prefs = await SharedPreferences.getInstance();
    final rememberCorreo = prefs.getString('remember_correo');
    final rememberPassword = prefs.getString('remember_password');
    final rememberToken = prefs.getString('remember_token');
    final authToken = prefs.getString('auth_token');
    final keepSession = prefs.getBool('keep_session');
    debugPrint('[REMEMBER][$tag] authToken=${authToken != null ? "set" : "null"} rememberToken=${rememberToken != null ? "set" : "null"} correo=$rememberCorreo pass=${rememberPassword != null ? "set" : "null"} keep_session=$keepSession');
  }

  // Verificar si el usuario está autenticado
  Future<void> _checkAuthStatus() async {
    debugPrint('--- _checkAuthStatus START ---');
    try {
      final token = await _apiService.getToken();
      debugPrint('Token from storage: $token');
      await _logRememberState('bootstrap-start');
      if (token != null) {
        debugPrint('Calling obtenerPerfil()...');
        final success = await obtenerPerfil();
        debugPrint('obtenerPerfil() success: $success');
        if (success) return;
      }
      // Intentar remember con credenciales guardadas
      final prefs = await SharedPreferences.getInstance();
      final correo = prefs.getString('remember_correo');
      final password = prefs.getString('remember_password');
      _mantenerSesion = prefs.getBool('keep_session') ?? false;
      debugPrint('Remember credentials: correo=$correo, password=${password != null ? "***" : "null"}, keep_session=$_mantenerSesion');
      if (correo != null && password != null) {
        // Intentar login silencioso
        debugPrint('Calling iniciarSesion silencioso...');
        final success = await iniciarSesion(correo: correo, password: password, recordar: true, silencioso: true);
        debugPrint('iniciarSesion silencioso success: $success');
        await _logRememberState('bootstrap-after-silent-login');
      }
    } finally {
      _authBootstrapDone = true;
      debugPrint('--- _checkAuthStatus END (isAuthenticated: $_isAuthenticated) ---');
      notifyListeners();
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
    debugPrint('[LOGIN] iniciarSesion correo=$correo recordar=$recordar silencioso=$silencioso mantenerSesion=$_mantenerSesion');
    await _logRememberState('login-before-api');

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
          debugPrint('[LOGIN] remember guardado por checkbox');
        }
        if (_mantenerSesion) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('remember_correo', correo);
          await prefs.setString('remember_password', password);
          debugPrint('[LOGIN] remember guardado por mantener sesión');
        }
        await _logRememberState('login-after-save');
        _setLoading(false);
        return true;
      } else {
        debugPrint('[LOGIN] login fallido message=${result['message']}');
        if (!silencioso) _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('[LOGIN] excepción en iniciarSesion: $e');
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
        _cerrarSesionLocal(clearRemember: false);
        return false;
      }
    } catch (e) {
      _cerrarSesionLocal(clearRemember: false);
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
    _cerrarSesionLocal(context: context, clearRemember: true);
  }

  // Cerrar sesión local
  void _cerrarSesionLocal({BuildContext? context, bool clearRemember = false}) {
    _isAuthenticated = false;
    _user = null;
    debugPrint('[AUTH] _cerrarSesionLocal clearRemember=$clearRemember');
    if (clearRemember) {
      // Limpiar datos remember
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('remember_correo');
        prefs.remove('remember_password');
        prefs.remove('remember_token');
        if (!_mantenerSesion) {
          prefs.remove('keep_session');
        }
        debugPrint('[AUTH] remember limpiado en logout');
      });
    }
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
    _cerrarSesionLocal(context: context, clearRemember: false);
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

