import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/evento_calendario.dart';
import '../../services/api_service.dart';

class CalendarioService {
  static const String _keyEventosCalendario = 'eventos_calendario_guardados';

  // Obtener todos los eventos del calendario
  static Future<List<EventoCalendario>> obtenerEventos({String? currentUserId}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventosJson = prefs.getString(_keyEventosCalendario);
    
    if (eventosJson == null || eventosJson.isEmpty) {
      return [];
    }
    
    final List<dynamic> eventosList = json.decode(eventosJson);
    final todos = eventosList.map((json) => EventoCalendario.fromJson(json)).toList();
    if (currentUserId == null) return todos;
    // Filtrar solo eventos del usuario actual; eventos antiguos sin userId se consideran "huérfanos" y se descartan
    return todos.where((e) => e.userId == null ? false : e.userId == currentUserId).toList();
  }

  // Migrar eventos legacy (sin mascotaId) asignándoles uno específico cuando el usuario
  // abre la vista filtrada por esa mascota. Devuelve número de eventos actualizados.
  static Future<int> migrarEventosSinMascota({required String mascotaId, String? mascotaNombre, String? mascotaFoto}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventosJson = prefs.getString(_keyEventosCalendario);
    if (eventosJson == null || eventosJson.isEmpty) return 0;
    final List<dynamic> eventosList = json.decode(eventosJson);
    bool huboCambios = false;
    final eventos = eventosList.map((e) => EventoCalendario.fromJson(Map<String,dynamic>.from(e))).toList();
    for (int i=0; i<eventos.length; i++) {
      final ev = eventos[i];
      if (ev.mascotaId == null) {
        eventos[i] = EventoCalendario(
          id: ev.id,
          titulo: ev.titulo,
          descripcion: ev.descripcion,
          categoria: ev.categoria,
          fechaHora: ev.fechaHora,
          tipoRecordatorio: ev.tipoRecordatorio,
          frecuencia: ev.frecuencia,
          avisos: ev.avisos,
          activo: ev.activo,
          userId: ev.userId,
          mascotaId: mascotaId,
          mascotaNombre: mascotaNombre,
          mascotaFoto: mascotaFoto,
        );
        huboCambios = true;
      }
    }
    if (huboCambios) {
      await prefs.setString(_keyEventosCalendario, json.encode(eventos.map((e) => e.toJson()).toList()));
      return eventos.where((e) => e.mascotaId == mascotaId).length;
    }
    return 0;
  }

  // Actualizar el nombre (y opcionalmente foto) de una mascota en todos los eventos que la referencian.
  // Devuelve cuántos eventos fueron modificados.
  static Future<int> actualizarNombreMascotaEnEventos(String mascotaId, String nuevoNombre, {String? nuevaFoto}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventosJson = prefs.getString(_keyEventosCalendario);
    if (eventosJson == null || eventosJson.isEmpty) return 0;
    final List<dynamic> eventosList = json.decode(eventosJson);
    bool huboCambios = false;
    int modificados = 0;
    final eventos = eventosList.map((e) => EventoCalendario.fromJson(Map<String,dynamic>.from(e))).toList();
    for (int i=0; i<eventos.length; i++) {
      final ev = eventos[i];
      if (ev.mascotaId == mascotaId && ev.mascotaNombre != nuevoNombre) {
        eventos[i] = EventoCalendario(
          id: ev.id,
          titulo: ev.titulo,
          descripcion: ev.descripcion,
          categoria: ev.categoria,
          fechaHora: ev.fechaHora,
          tipoRecordatorio: ev.tipoRecordatorio,
          frecuencia: ev.frecuencia,
          avisos: ev.avisos,
          activo: ev.activo,
          userId: ev.userId,
          mascotaId: ev.mascotaId,
          mascotaNombre: nuevoNombre,
          mascotaFoto: nuevaFoto ?? ev.mascotaFoto,
        );
        huboCambios = true;
        modificados++;
      }
    }
    if (huboCambios) {
      await prefs.setString(_keyEventosCalendario, json.encode(eventos.map((e) => e.toJson()).toList()));
    }
    return modificados;
  }

  // Obtener todos los eventos (método de instancia)
  Future<List<EventoCalendario>> obtenerEventosInstancia({String? currentUserId}) async {
    return await CalendarioService.obtenerEventos(currentUserId: currentUserId);
  }

  // Guardar un nuevo evento del calendario
  static Future<bool> guardarEvento(EventoCalendario evento, {String? currentUserId}) async {
    try {
      final List<EventoCalendario> eventos = await obtenerEventos();
      // Adjuntar userId si llega
      final withUser = EventoCalendario(
        id: evento.id,
        titulo: evento.titulo,
        descripcion: evento.descripcion,
        categoria: evento.categoria,
        fechaHora: evento.fechaHora,
        tipoRecordatorio: evento.tipoRecordatorio,
        frecuencia: evento.frecuencia,
        avisos: evento.avisos,
        activo: evento.activo,
        userId: currentUserId ?? evento.userId,
        // NUEVO: copiar campos de mascota para que no se pierdan al persistir
        mascotaId: evento.mascotaId,
        mascotaNombre: evento.mascotaNombre,
        mascotaFoto: evento.mascotaFoto,
      );
      eventos.add(withUser);
      
      final prefs = await SharedPreferences.getInstance();
      final String eventosJson = json.encode(eventos.map((e) => e.toJson()).toList());
      
      return await prefs.setString(_keyEventosCalendario, eventosJson);
    } catch (e) {
      return false;
    }
  }

  // Crear un nuevo evento del calendario (método de instancia)
  Future<void> crearEvento(EventoCalendario evento, {String? currentUserId}) async {
    final bool resultado = await CalendarioService.guardarEvento(evento, currentUserId: currentUserId);
    if (!resultado) {
      throw Exception('No se pudo guardar el evento');
    }
  }

  // Eliminar un evento del calendario
  static Future<bool> eliminarEvento(String id) async {
    try {
      final List<EventoCalendario> eventos = await obtenerEventos();
      eventos.removeWhere((evento) => evento.id == id);
      
      final prefs = await SharedPreferences.getInstance();
      final String eventosJson = json.encode(eventos.map((e) => e.toJson()).toList());
      
      return await prefs.setString(_keyEventosCalendario, eventosJson);
    } catch (e) {
      return false;
    }
  }

  // Actualizar un evento existente
  static Future<bool> actualizarEvento(EventoCalendario eventoActualizado) async {
    try {
      final List<EventoCalendario> eventos = await obtenerEventos();
      final int index = eventos.indexWhere((e) => e.id == eventoActualizado.id);
      
      if (index != -1) {
        eventos[index] = eventoActualizado;
        
        final prefs = await SharedPreferences.getInstance();
        final String eventosJson = json.encode(eventos.map((e) => e.toJson()).toList());
        
        return await prefs.setString(_keyEventosCalendario, eventosJson);
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // Obtener recordatorios de vacunas desde el backend
  static Future<List<Map<String, dynamic>>> obtenerRecordatoriosVacunas() async {
    try {
      final apiService = ApiService();
      final response = await apiService.obtenerRecordatoriosVacunas();
      if (response['ok'] == true && response['recordatorios'] != null) {
        return List<Map<String, dynamic>>.from(response['recordatorios']);
      }
      return [];
    } catch (e) {
      print('Error al obtener recordatorios de vacunas: $e');
      return [];
    }
  }

  // Eliminar todos los eventos locales que no correspondan al usuario actual
  static Future<void> purgarEventosDeOtrosUsuarios(String currentUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventosJson = prefs.getString(_keyEventosCalendario);
    if (eventosJson == null || eventosJson.isEmpty) return;
    final List<dynamic> eventosList = json.decode(eventosJson);
    final filtrados = eventosList.where((raw) {
      try {
        final map = raw as Map<String,dynamic>;
        final uid = map['userId'];
        return uid == currentUserId; // descartar los demás
      } catch (_) { return false; }
    }).toList();
    await prefs.setString(_keyEventosCalendario, json.encode(filtrados));
  }

}
