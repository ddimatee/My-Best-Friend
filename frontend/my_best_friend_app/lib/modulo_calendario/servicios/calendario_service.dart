import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/evento_calendario.dart';

class CalendarioService {
  static const String _keyEventosCalendario = 'eventos_calendario_guardados';

  // Obtener todos los eventos del calendario
  static Future<List<EventoCalendario>> obtenerEventos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventosJson = prefs.getString(_keyEventosCalendario);
    
    if (eventosJson == null || eventosJson.isEmpty) {
      return [];
    }
    
    final List<dynamic> eventosList = json.decode(eventosJson);
    return eventosList.map((json) => EventoCalendario.fromJson(json)).toList();
  }

  // Obtener todos los eventos (método de instancia)
  Future<List<EventoCalendario>> obtenerEventosInstancia() async {
    return await CalendarioService.obtenerEventos();
  }

  // Guardar un nuevo evento del calendario
  static Future<bool> guardarEvento(EventoCalendario evento) async {
    try {
      final List<EventoCalendario> eventos = await obtenerEventos();
      eventos.add(evento);
      
      final prefs = await SharedPreferences.getInstance();
      final String eventosJson = json.encode(eventos.map((e) => e.toJson()).toList());
      
      return await prefs.setString(_keyEventosCalendario, eventosJson);
    } catch (e) {
      return false;
    }
  }

  // Crear un nuevo evento del calendario (método de instancia)
  Future<void> crearEvento(EventoCalendario evento) async {
    final bool resultado = await CalendarioService.guardarEvento(evento);
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
}
