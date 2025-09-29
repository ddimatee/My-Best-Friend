import 'dart:convert';
import 'dart:io' show Platform; // Ignorado en web si no se usa directamente allí
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Detectar plataforma para seleccionar host correcto (localhost no funciona en emulador Android)
  static String get baseUrl {
    const String port = '3000';
    // Permitir override en build: --dart-define=API_BASE=http://tu-ip:3000
    const String override = String.fromEnvironment('API_BASE', defaultValue: '');
    if (override.isNotEmpty) {
      return '$override/api';
    }
    // Detectar Android emulator
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:$port/api';
      }
      if (Platform.isIOS) {
        return 'http://localhost:$port/api';
      }
    } catch (_) {
      // En web u otros entornos donde Platform no aplica
    }
    return 'http://localhost:$port/api';
  }
  
  // Headers comunes
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers con token de autenticación
  Future<Map<String, String>> get headersWithAuth async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Obtener token de SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Guardar token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Eliminar token
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // =============== USUARIOS ===============
  
  // Registrar usuario
  Future<Map<String, dynamic>> registrarUsuario({
    required String nombre,
    required String apellido,
    required String correo,
    required String celular,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/registro'),
        headers: headers,
        body: json.encode({
          'nombre': nombre,
          'apellido': apellido,
          'correo': correo,
          'celular': celular,
          'contraseña': password,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Iniciar sesión
  Future<Map<String, dynamic>> iniciarSesion({
    required String correo,
    required String password,
    bool recordar = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/login'),
        headers: headers,
        body: json.encode({
          'correo': correo,
          'contraseña': password,
          'recordar': recordar,
        }),
      );

      final result = _handleResponse(response);
      
      // Si el login es exitoso, guardar el token
      if (result['success'] && result['data']?['token'] != null) {
        await saveToken(result['data']['token']);
        // Guardar rememberToken si llega
        final rt = result['data']['rememberToken'];
        if (rt is String && rt.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('remember_token', rt);
        }
      }
      
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener perfil del usuario
  Future<Map<String, dynamic>> obtenerPerfil() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/perfil'),
        headers: await headersWithAuth,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // =============== MASCOTAS ===============
  
  // Obtener mascotas del usuario
  Future<Map<String, dynamic>> obtenerMascotas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mascotas'),
        headers: await headersWithAuth,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Crear nueva mascota
  Future<Map<String, dynamic>> crearMascota({
    required String nombre,
    required String especie,
    required String raza,
    required DateTime fechaNacimiento,
    required String sexo,
    String? descripcion,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mascotas'),
        headers: await headersWithAuth,
        body: json.encode({
          'nombre': nombre,
          'especie': especie,
          'raza': raza,
          'fechaNacimiento': fechaNacimiento.toIso8601String(),
          'sexo': sexo,
          'descripcion': descripcion,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // =============== EVENTOS ===============
  
  // Obtener eventos de una mascota
  Future<Map<String, dynamic>> obtenerEventos(String mascotaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/eventos/$mascotaId'),
        headers: await headersWithAuth,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Crear nuevo evento
  Future<Map<String, dynamic>> crearEvento({
    required String mascotaId,
    required String titulo,
    required String tipo,
    required DateTime fecha,
    String? descripcion,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/eventos'),
        headers: await headersWithAuth,
        body: json.encode({
          'mascotaId': mascotaId,
          'titulo': titulo,
          'tipo': tipo,
          'fecha': fecha.toIso8601String(),
          'descripcion': descripcion,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // =============== VACUNAS ===============
  
  // Obtener vacunas de una mascota
  Future<Map<String, dynamic>> obtenerVacunas(String mascotaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vacunas/$mascotaId'),
        headers: await headersWithAuth,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Crear nueva vacuna
  Future<Map<String, dynamic>> crearVacuna({
    required String mascotaId,
    required String nombre,
    required DateTime fecha,
    DateTime? proximaDosis,
    String? veterinario,
    String? notas,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vacunas'),
        headers: await headersWithAuth,
        body: json.encode({
          'mascotaId': mascotaId,
          'nombre': nombre,
          'fecha': fecha.toIso8601String(),
          'proximaDosis': proximaDosis?.toIso8601String(),
          'veterinario': veterinario,
          'notas': notas,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // =============== PESO ===============
  
  // Obtener registros de peso de una mascota
  Future<Map<String, dynamic>> obtenerRegistrosPeso(String mascotaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/peso/$mascotaId'),
        headers: await headersWithAuth,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Crear registro de peso
  Future<Map<String, dynamic>> crearRegistroPeso({
    required String mascotaId,
    required double peso,
    required DateTime fecha,
    String? notas,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/peso'),
        headers: await headersWithAuth,
        body: json.encode({
          'mascotaId': mascotaId,
          'peso': peso,
          'fecha': fecha.toIso8601String(),
          'notas': notas,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // =============== ÁLBUM ===============
  
  // Obtener fotos del álbum
  Future<Map<String, dynamic>> obtenerFotos(String mascotaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/album/$mascotaId'),
        headers: await headersWithAuth,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // =============== UTILIDADES ===============
  
  // Verificar conexión con el servidor
  Future<Map<String, dynamic>> verificarConexion() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/utils/info'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Manejar respuestas HTTP
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': body,
          'statusCode': response.statusCode,
        };
      } else {
        // Extraer mensaje del backend (puede venir en 'message' o 'error')
        String mensaje = (body['message'] ?? body['error'] ?? 'Error del servidor').toString();

        // Normalizar mensajes específicos de login
        if (response.statusCode == 404 && mensaje.toLowerCase().contains('usuario no encontrado')) {
          mensaje = 'El correo no está registrado';
        } else if (response.statusCode == 401 && mensaje.toLowerCase().contains('contraseña incorrecta')) {
          mensaje = 'La contraseña es incorrecta';
        }

        // Mensajes de validación (registro/login) express-validator usualmente vienen como array
        if (body is Map && body['errors'] is List) {
          final errors = body['errors'] as List;
            if (errors.isNotEmpty) {
              // Concatenar los mensajes de validación
              mensaje = errors.map((e) => e['msg']).join('. ');
            }
        }

        // Duplicate key Mongo (correo ya existe)
        if (mensaje.contains('E11000') && mensaje.toLowerCase().contains('correo')) {
          mensaje = 'El correo ya está registrado';
        }

        return {
          'success': false,
          'message': mensaje,
          'statusCode': response.statusCode,
          'data': body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al procesar respuesta: $e',
        'statusCode': response.statusCode,
      };
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await removeToken();
  }
}