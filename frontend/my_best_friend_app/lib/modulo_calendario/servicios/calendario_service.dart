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
