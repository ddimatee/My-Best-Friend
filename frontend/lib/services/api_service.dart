import 'dart:convert';
import 'dart:io' show Platform; // Ignorado en web si no se usa directamente allí
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

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
    final headers = <String, String>{};
    
    // Solo agregar Authorization si hay token
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    // Content-Type y Accept se agregan solo si no estamos en web o si es necesario
    headers['Content-Type'] = 'application/json; charset=utf-8';
    headers['Accept'] = 'application/json';
    
    return headers;
  }

  // Obtener token de SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Formatear fecha en hora local sin conversión a UTC
  String _formatearFechaLocal(DateTime fecha) {
    // MongoDB guarda en UTC, así que necesitamos enviar la hora ajustada
    // Si estamos en UTC-5 y queremos 15:00, MongoDB lo guardará como 20:00 UTC
    // Para que se muestre correctamente, enviamos la fecha TAL CUAL con zona horaria
    
    // Obtener el offset local en horas
    final offset = fecha.timeZoneOffset;
    final offsetHoras = offset.inHours;
    final offsetMinutos = offset.inMinutes.remainder(60).abs();
    
    // Formatear la fecha con la zona horaria
    final year = fecha.year.toString().padLeft(4, '0');
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');
    final hour = fecha.hour.toString().padLeft(2, '0');
    final minute = fecha.minute.toString().padLeft(2, '0');
    final second = fecha.second.toString().padLeft(2, '0');
    
    // Construir el string con zona horaria (ej: 2025-10-11T15:00:00-05:00)
    final signo = offset.isNegative ? '-' : '+';
    final offsetStr = '$signo${offsetHoras.abs().toString().padLeft(2, '0')}:${offsetMinutos.toString().padLeft(2, '0')}';
    
    return '$year-$month-${day}T$hour:$minute:$second$offsetStr';
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
  // Registrar token de dispositivo para push
  Future<Map<String,dynamic>> registrarDeviceToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notificaciones/token'),
        headers: await headersWithAuth,
        body: json.encode({ 'token': token })
      );
      return _handleResponse(response);
    } catch (e) { return { 'success': false, 'message': 'Error de conexión: $e' }; }
  }

  Future<Map<String,dynamic>> eliminarDeviceToken(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notificaciones/token'),
        headers: await headersWithAuth,
        body: json.encode({ 'token': token })
      );
      return _handleResponse(response);
    } catch (e) { return { 'success': false, 'message': 'Error de conexión: $e' }; }
  }
  
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

  // Actualizar perfil del usuario autenticado
  Future<Map<String, dynamic>> actualizarPerfil({
    required String id,
    String? nombre,
    String? apellido,
    String? correo,
    String? celular,
    String? fotoPerfil,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nombre != null) body['nombre'] = nombre;
      if (apellido != null) body['apellido'] = apellido;
      if (correo != null) body['correo'] = correo;
      if (celular != null) body['celular'] = celular;
      if (fotoPerfil != null) body['fotoPerfil'] = fotoPerfil;
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: await headersWithAuth,
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Subir foto de perfil (multipart)
  Future<Map<String, dynamic>> subirFotoPerfilUsuario({
    required String id,
    required List<int> bytes,
    required String filename,
    String? mimeType,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/usuarios/$id/foto');
      final request = http.MultipartRequest('POST', uri);
      final headersAuth = await headersWithAuth; // contiene Authorization
      // Quitar content-type json para multipart
      headersAuth.remove('Content-Type');
      request.headers.addAll(headersAuth);
      final multipartFile = http.MultipartFile.fromBytes(
        'foto',
        bytes,
        filename: filename,
      );
      request.files.add(multipartFile);
      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);
      return _handleResponse(resp);
    } catch (e) {
      return {'success': false, 'message': 'Error subiendo foto: $e'};
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

  Future<Map<String,dynamic>> actualizarMascota({required String id, required Map<String,dynamic> data}) async {
    try {
      final body = <String,dynamic>{};
      // Permitimos sólo campos conocidos
      const permitidos = {
        'nombre','especie','raza','fechaNacimiento','fecha_nac','sexo','descripcion','oculto','estiloVida','cuidaConAlguien','cuidador','fotoPerfil'
      };
      for (final entry in data.entries) {
        if (permitidos.contains(entry.key) && entry.value != null) {
          body[entry.key] = entry.value;
        }
      }
      final response = await http.put(
        Uri.parse('$baseUrl/mascotas/$id'),
        headers: await headersWithAuth,
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String,dynamic>> eliminarMascota(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/mascotas/$id'),
        headers: await headersWithAuth,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String,dynamic>> subirFotoMascota({required String id, required String filePath}) async {
    try {
      final token = await getToken();
      final uri = Uri.parse('$baseUrl/mascotas/$id/foto');
      final request = http.MultipartRequest('POST', uri);
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('foto', filePath));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // =============== EVENTOS ===============
  // Backend actual usa /api/eventos con filtros en query
  Future<Map<String, dynamic>> obtenerEventos({
    String? fechaISO,
    String? mascotaId,
    String? tipo,
    bool? completado,
  }) async {
    try {
      final params = <String, String>{};
      if (fechaISO != null) params['fecha'] = fechaISO; // yyyy-MM-dd
      if (mascotaId != null) params['mascota'] = mascotaId;
      if (tipo != null) params['tipo'] = tipo;
      if (completado != null) params['completado'] = completado.toString();
      final uri = Uri.parse('$baseUrl/eventos').replace(queryParameters: params.isEmpty ? null : params);
      final response = await http.get(
        uri,
        headers: await headersWithAuth,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> obtenerEventosCalendario({
    required DateTime inicio,
    required DateTime fin,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/eventos/calendario').replace(queryParameters: {
        'fechaInicio': inicio.toIso8601String(),
        'fechaFin': fin.toIso8601String(),
      });
      final response = await http.get(uri, headers: await headersWithAuth);
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> crearEvento({
    required String mascotaId,
    required String titulo,
    required String tipo,
    required DateTime fecha,
    required String hora, // backend separa fecha y hora
    String? descripcion,
    bool recordatorioActivo = true,
    int minutosAntes = 30,
    String prioridad = 'media',
  }) async {
    try {
      print('🆕 crearEvento iniciado');
      print('   mascotaId: $mascotaId');
      print('   titulo: $titulo');
      print('   tipo: $tipo');
      print('   fecha: $fecha');
      print('   hora: $hora');
      
      // Enviar fecha en formato YYYY-MM-DD (solo fecha, sin hora ni timezone)
      final fechaStr = '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
      print('   fechaStr: $fechaStr');
      
      final body = {
        'mascota': mascotaId,
        'titulo': titulo,
        'tipo': tipo,
        'fecha': fechaStr,
        'hora': hora,
        'descripcion': descripcion,
        'prioridad': prioridad,
        'recordatorio': {
          'activo': recordatorioActivo,
          'tiempoAntes': minutosAntes,
        }
      };
      print('   body: ${json.encode(body)}');
      
      final headers = await headersWithAuth;
      print('   headers: $headers');
      print('   URL: $baseUrl/eventos');
      
      final response = await http.post(
        Uri.parse('$baseUrl/eventos'),
        headers: headers,
        body: json.encode(body),
      );
      
      print('   response status: ${response.statusCode}');
      print('   response body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e, stackTrace) {
      print('💥 Error en crearEvento: $e');
      print('   Stack trace: $stackTrace');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> actualizarEvento({
    required String eventoId,
    String? titulo,
    String? tipo,
    DateTime? fecha,
    String? hora,
    String? descripcion,
    String? prioridad,
    bool? completado,
    bool? recordatorioActivo,
    int? minutosAntes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (titulo != null) body['titulo'] = titulo;
      if (tipo != null) body['tipo'] = tipo;
      if (fecha != null) {
        // Enviar fecha en formato YYYY-MM-DD (solo fecha, sin hora ni timezone)
        final fechaStr = '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
        body['fecha'] = fechaStr;
      }
      if (hora != null) body['hora'] = hora;
      if (descripcion != null) body['descripcion'] = descripcion;
      if (prioridad != null) body['prioridad'] = prioridad;
      if (completado != null) body['completado'] = completado;
      if (recordatorioActivo != null || minutosAntes != null) {
        body['recordatorio'] = {
          if (recordatorioActivo != null) 'activo': recordatorioActivo,
          if (minutosAntes != null) 'tiempoAntes': minutosAntes,
        };
      }
      final response = await http.put(
        Uri.parse('$baseUrl/eventos/$eventoId'),
        headers: await headersWithAuth,
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return { 'success': false, 'message': 'Error de conexión: $e' };
    }
  }

  Future<Map<String,dynamic>> eliminarEvento(String id) async {
    try {
      print('=== ELIMINANDO EVENTO ===');
      print('ID: $id');
      print('URL: $baseUrl/eventos/$id');
      final response = await http.delete(
        Uri.parse('$baseUrl/eventos/$id'),
        headers: await headersWithAuth,
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      print('Error en eliminarEvento: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }


  // =============== VACUNAS ===============
  
  // Obtener vacunas (opcionalmente por mascota / estado)
  Future<Map<String, dynamic>> obtenerVacunas({ String? mascotaId, String? estado }) async {
    try {
      final params = <String, String>{};
      if (mascotaId != null) params['mascota'] = mascotaId;
      if (estado != null) params['estado'] = estado;
      final uri = Uri.parse('$baseUrl/vacunas').replace(queryParameters: params.isEmpty ? null : params);
      final response = await http.get(uri, headers: await headersWithAuth);
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> crearVacuna({
  required String mascotaId,
  required String nombre,
  required DateTime fechaAplicacion,
  DateTime? fechaVencimiento,
  String? observaciones,
  String? ubicacion,
  String? lote,
  String? laboratorio,
  String? vetNombre,
  String? vetClinica,
  String? vetTelefono,
  bool? recordatorio,
  TimeOfDay? horaRecordatorio,
  }) async {
    try {
      // Si se activa el recordatorio, combinamos fecha con hora
      DateTime? fechaRecordatorio;
      if (recordatorio == true) {
        final hora = horaRecordatorio ?? TimeOfDay(hour: 9, minute: 0);
        fechaRecordatorio = DateTime(
          fechaAplicacion.year,
          fechaAplicacion.month,
          fechaAplicacion.day,
          hora.hour,
          hora.minute,
        );
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/vacunas'),
        headers: await headersWithAuth,
        body: json.encode({
          'mascota': mascotaId,
          'nombre': nombre,
          'fechaAplicacion': fechaAplicacion.toIso8601String(),
          if (fechaVencimiento != null) 'fechaVencimiento': fechaVencimiento.toIso8601String(),
          if (observaciones != null) 'observaciones': observaciones,
          if (ubicacion != null) 'ubicacion': ubicacion,
          if (lote != null) 'lote': lote,
          if (laboratorio != null) 'laboratorio': laboratorio,
          if (recordatorio != null) 'recordatorio': {
            'activo': recordatorio,
            if (fechaRecordatorio != null) 'fechaRecordatorio': _formatearFechaLocal(fechaRecordatorio),
          },
          if (vetNombre != null || vetClinica != null || vetTelefono != null) 'veterinario': {
            if (vetNombre != null) 'nombre': vetNombre,
            if (vetClinica != null) 'clinica': vetClinica,
            if (vetTelefono != null) 'telefono': vetTelefono,
          },
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> actualizarVacuna({
  required String vacunaId,
  String? mascotaId,
  String? nombre,
  DateTime? fechaAplicacion,
  DateTime? fechaVencimiento,
  String? observaciones,
  String? ubicacion,
  String? lote,
  String? laboratorio,
  String? vetNombre,
  String? vetClinica,
  String? vetTelefono,
  bool? recordatorio,
  TimeOfDay? horaRecordatorio,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (mascotaId != null) {
        body['mascota'] = mascotaId;
        body['mascotaId'] = mascotaId;
      }
      if (nombre != null) body['nombre'] = nombre;
      if (fechaAplicacion != null) body['fechaAplicacion'] = fechaAplicacion.toIso8601String();
      if (fechaVencimiento != null) body['fechaVencimiento'] = fechaVencimiento.toIso8601String();
      if (observaciones != null) body['observaciones'] = observaciones;
      if (ubicacion != null) body['ubicacion'] = ubicacion;
      if (lote != null) body['lote'] = lote;
      if (laboratorio != null) body['laboratorio'] = laboratorio;
      
      // Si se activa el recordatorio, construir fecha con hora
      if (recordatorio == true && horaRecordatorio != null) {
        // Usar la fecha de aplicación si existe, si no usar la fecha actual
        final fechaBase = fechaAplicacion ?? DateTime.now();
        
        // Construir fecha en hora local con la hora seleccionada
        final fechaRecordatorio = DateTime(
          fechaBase.year,
          fechaBase.month,
          fechaBase.day,
          horaRecordatorio.hour,
          horaRecordatorio.minute,
        );
        
        body['recordatorio'] = {
          'activo': recordatorio,
          'fechaRecordatorio': _formatearFechaLocal(fechaRecordatorio),
        };
      } else if (recordatorio != null) {
        body['recordatorio'] = {'activo': recordatorio};
      }
      
      if (vetNombre != null || vetClinica != null || vetTelefono != null) {
        body['veterinario'] = {
          if (vetNombre != null) 'nombre': vetNombre,
          if (vetClinica != null) 'clinica': vetClinica,
          if (vetTelefono != null) 'telefono': vetTelefono,
        };
      }
      final response = await http.put(
        Uri.parse('$baseUrl/vacunas/$vacunaId'),
        headers: await headersWithAuth,
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );
      return _handleResponse(response);
    } catch (e) {
      return { 'success': false, 'message': 'Error de conexión: $e' };
    }
  }

  Future<Map<String, dynamic>> eliminarVacuna(String vacunaId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/vacunas/$vacunaId'),
        headers: await headersWithAuth,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );
      return _handleResponse(response);
    } catch (e) {
      return { 'success': false, 'message': 'Error de conexión: $e' };
    }
  }

  // Obtener recordatorios de vacunas
  Future<Map<String, dynamic>> obtenerRecordatoriosVacunas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vacunas/recordatorios'),
        headers: await headersWithAuth,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );
      
      if (response.statusCode == 200) {
        final recordatorios = json.decode(response.body);
        return { 'ok': true, 'recordatorios': recordatorios };
      } else {
        return { 'ok': false, 'mensaje': 'Error al obtener recordatorios' };
      }
    } catch (e) {
      return { 'ok': false, 'mensaje': 'Error de conexión: $e' };
    }
  }

  // =============== PESO ===============
  
  // Obtener registros de peso (con filtros opcionales)
  Future<Map<String, dynamic>> obtenerRegistrosPeso({ String? mascotaId, DateTime? inicio, DateTime? fin, int? limite }) async {
    try {
      final params = <String, String>{};
      if (mascotaId != null) params['mascota'] = mascotaId;
      if (inicio != null && fin != null) {
        params['fechaInicio'] = inicio.toIso8601String();
        params['fechaFin'] = fin.toIso8601String();
      }
      if (limite != null) params['limite'] = limite.toString();
      final uri = Uri.parse('$baseUrl/peso').replace(queryParameters: params.isEmpty ? null : params);
      final response = await http.get(uri, headers: await headersWithAuth);
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> crearRegistroPeso({
    required String mascotaId,
    required double peso,
    DateTime? fecha,
    String? observaciones,
    String tipoRegistro = 'rutina',
  }) async {
    try {
      final body = {
        'mascota': mascotaId,
        'peso': peso,
        if (fecha != null) 'fecha': _formatearFechaLocal(fecha.toLocal()),
        if (observaciones != null) 'observaciones': observaciones,
        'tipoRegistro': tipoRegistro,
      };
      final response = await http.post(
        Uri.parse('$baseUrl/peso'),
        headers: await headersWithAuth,
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> actualizarRegistroPeso({
    required String registroId,
    double? peso,
    DateTime? fecha,
    String? observaciones,
    String? tipoRegistro,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (peso != null) body['peso'] = peso;
      if (fecha != null) body['fecha'] = _formatearFechaLocal(fecha.toLocal());
      if (observaciones != null) body['observaciones'] = observaciones;
      if (tipoRegistro != null) body['tipoRegistro'] = tipoRegistro;
      final response = await http.put(
        Uri.parse('$baseUrl/peso/$registroId'),
        headers: await headersWithAuth,
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return { 'success': false, 'message': 'Error de conexión: $e' };
    }
  }

  Future<Map<String, dynamic>> eliminarRegistroPeso(String registroId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/peso/$registroId'),
        headers: await headersWithAuth,
      );
      return _handleResponse(response);
    } catch (e) {
      return { 'success': false, 'message': 'Error de conexión: $e' };
    }
  }

  // =============== ÁLBUM ===============
  
  // Álbum: obtener fotos (paginadas y con filtros)
  Future<Map<String, dynamic>> obtenerFotos({ String? mascotaId, String? etiqueta, bool? esPortada, int limite = 20, int pagina = 1 }) async {
    try {
      final params = <String, String>{
        'limite': limite.toString(),
        'pagina': pagina.toString(),
      };
      if (mascotaId != null) params['mascota'] = mascotaId;
      if (etiqueta != null) params['etiqueta'] = etiqueta;
      if (esPortada != null) params['esPortada'] = esPortada.toString();
      final uri = Uri.parse('$baseUrl/album').replace(queryParameters: params);
      final response = await http.get(uri, headers: await headersWithAuth);
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> subirFoto({
    required String mascotaId,
    required String url,
    String? titulo,
    String? descripcion,
    String? ubicacion,
    List<String>? etiquetas,
    bool esPortada = false,
    DateTime? fecha,
  }) async {
    try {
      final body = {
        'mascota': mascotaId,
        'url': url,
        if (titulo != null) 'titulo': titulo,
        if (descripcion != null) 'descripcion': descripcion,
        if (ubicacion != null) 'ubicacion': ubicacion,
        if (etiquetas != null && etiquetas.isNotEmpty) 'etiquetas': etiquetas,
        'esPortada': esPortada,
        if (fecha != null) 'fecha': fecha.toIso8601String(),
      };
      final response = await http.post(
        Uri.parse('$baseUrl/album'),
        headers: await headersWithAuth,
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return { 'success': false, 'message': 'Error de conexión: $e' };
    }
  }

  Future<Map<String, dynamic>> actualizarFoto({
    required String fotoId,
    String? titulo,
    String? descripcion,
    String? ubicacion,
    List<String>? etiquetas,
    bool? esPortada,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (titulo != null) body['titulo'] = titulo;
      if (descripcion != null) body['descripcion'] = descripcion;
      if (ubicacion != null) body['ubicacion'] = ubicacion;
      if (etiquetas != null) body['etiquetas'] = etiquetas;
      if (esPortada != null) body['esPortada'] = esPortada;
      final response = await http.put(
        Uri.parse('$baseUrl/album/$fotoId'),
        headers: await headersWithAuth,
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return { 'success': false, 'message': 'Error de conexión: $e' };
    }
  }

  Future<Map<String, dynamic>> eliminarFoto(String fotoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/album/$fotoId'),
        headers: await headersWithAuth,
      );
      return _handleResponse(response);
    } catch (e) {
      return { 'success': false, 'message': 'Error de conexión: $e' };
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
        if (body is Map<String, dynamic> && (body.containsKey('success') || body.containsKey('data'))) {
          final dynamic nestedSuccess = body['success'];
          return {
            'success': nestedSuccess is bool ? nestedSuccess : true,
            'data': body.containsKey('data') ? body['data'] : body,
            if (body['message'] != null) 'message': body['message'],
            if (body['error'] != null) 'error': body['error'],
            'statusCode': response.statusCode,
          };
        }
        return {
          'success': true,
          'data': body,
          'statusCode': response.statusCode,
        };
      } else {
        // Extraer mensaje del backend (puede venir en 'message' o 'error')
        String mensaje;
        if (body is Map) {
          mensaje = (body['message'] ?? body['error'] ?? 'Error del servidor').toString();
        } else {
          mensaje = 'Error del servidor';
        }

        // Normalizar mensajes específicos de login
        if (response.statusCode == 404 && mensaje.toLowerCase().contains('usuario no encontrado')) {
          mensaje = 'El correo no está registrado';
        } else if (response.statusCode == 401 && mensaje.toLowerCase().contains('contraseña incorrecta')) {
          mensaje = 'La contraseña es incorrecta';
        }

        // Mensajes de validación (registro/login) express-validator usualmente vienen como array
        if (body is Map) {
          if (body['errors'] is List) {
            final errors = body['errors'] as List;
            if (errors.isNotEmpty) {
              mensaje = errors
                  .map((e) => (e is Map && (e['msg'] != null)) ? e['msg'] : e.toString())
                  .join('. ');
            }
          } else if (body['detalles'] is List) {
            // Backend está enviando 'detalles' en lugar de 'errors'
            final detalles = body['detalles'] as List;
            if (detalles.isNotEmpty) {
              final detallesMsg = detalles
                  .map((e) => (e is Map && (e['msg'] != null)) ? e['msg'] : e.toString())
                  .join('. ');
              // Evitar duplicar si mensaje principal ya es genérico
              if (!mensaje.contains(detallesMsg)) {
                mensaje = '$mensaje: $detallesMsg';
              }
            }
          }
        }

        // Duplicate key Mongo (correo ya existe)
        if (mensaje.contains('E11000') && mensaje.toLowerCase().contains('correo')) {
          mensaje = 'El correo ya está registrado';
        }

        return {
          'success': false,
          'message': mensaje,
          'code': response.statusCode,
          'data': body,
          'unauthorized': response.statusCode == 401,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al procesar respuesta: $e',
        'code': response.statusCode,
      };
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await removeToken();
  }

  // Eliminar cuenta del usuario autenticado
  Future<Map<String, dynamic>> eliminarCuenta(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: await headersWithAuth,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Guardar preferencia de mantener sesión
  Future<void> setMantenerSesion(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keep_session', value);
  }

  Future<bool> getMantenerSesion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('keep_session') ?? false;
  }

  // Helper para envolver peticiones desde UI/Providers y disparar callback si 401
  Future<Map<String,dynamic>> guard(Future<Map<String,dynamic>> Function() call, {Future<void> Function()? onUnauthorized}) async {
    final resp = await call();
    if (resp['unauthorized'] == true && onUnauthorized != null) {
      await onUnauthorized();
    }
    return resp;
  }

  // ================= RECORDATORIOS (Calenario local sincronizado) ================
  Future<Map<String,dynamic>> crearRecordatorioBackend({
    required String titulo,
    required String descripcion,
    required String categoria,
    required DateTime fechaHora,
    required String tipoRecordatorio,
    required String frecuencia,
    required List<Map<String,dynamic>> avisos,
    required String mascotaId,
    String? mascotaNombre,
    String? userId,
    bool activo = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recordatorios'),
        headers: await headersWithAuth,
        body: json.encode({
          'titulo': titulo,
          'descripcion': descripcion,
          'categoria': categoria,
            'fechaHora': fechaHora.toIso8601String(),
          'tipoRecordatorio': tipoRecordatorio,
          'frecuencia': frecuencia,
          'avisos': avisos,
          'mascotaId': mascotaId,
          if (mascotaNombre != null) 'mascotaNombre': mascotaNombre,
          if (userId != null) 'userId': userId,
          'activo': activo,
        })
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String,dynamic>> listarRecordatoriosBackend({String? mascotaId, DateTime? desde, DateTime? hasta, bool? activo}) async {
    final params = <String,String>{};
    if (mascotaId != null && mascotaId.isNotEmpty) params['mascotaId'] = mascotaId;
    if (desde != null) params['desde'] = desde.toIso8601String();
    if (hasta != null) params['hasta'] = hasta.toIso8601String();
    if (activo != null) params['activo'] = activo.toString();
    final qs = params.isEmpty ? '' : ('?' + params.entries.map((e)=>'${e.key}=${Uri.encodeComponent(e.value)}').join('&'));
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recordatorios$qs'),
        headers: await headersWithAuth,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String,dynamic>> actualizarRecordatorioBackend({
    required String id,
    Map<String,dynamic>? cambios,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/recordatorios/$id'),
        headers: await headersWithAuth,
        body: json.encode(cambios ?? {}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String,dynamic>> eliminarRecordatorioBackend(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/recordatorios/$id'),
        headers: await headersWithAuth,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}