import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/evento.dart';

class EventoService {
  static const String _keyEventos = 'eventos_guardados';

  // Obtener todos los eventos
  static Future<List<Evento>> obtenerEventos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventosJson = prefs.getString(_keyEventos);
    
    if (eventosJson == null || eventosJson.isEmpty) {
      return [];
    }
    
    final List<dynamic> eventosList = json.decode(eventosJson);
    return eventosList.map((json) => Evento.fromJson(json)).toList();
  }

  // Guardar un nuevo evento
  static Future<bool> guardarEvento(Evento evento) async {
    try {
      final List<Evento> eventos = await obtenerEventos();
      eventos.add(evento);
      
      final prefs = await SharedPreferences.getInstance();
      final String eventosJson = json.encode(eventos.map((e) => e.toJson()).toList());
      
      return await prefs.setString(_keyEventos, eventosJson);
    } catch (e) {
      return false;
    }
  }

  // Eliminar un evento
  static Future<bool> eliminarEvento(String id) async {
    try {
      final List<Evento> eventos = await obtenerEventos();
      eventos.removeWhere((evento) => evento.id == id);
      
      final prefs = await SharedPreferences.getInstance();
      final String eventosJson = json.encode(eventos.map((e) => e.toJson()).toList());
      
      return await prefs.setString(_keyEventos, eventosJson);
    } catch (e) {
      return false;
    }
  }

  // Actualizar un evento existente
  static Future<bool> actualizarEvento(Evento eventoActualizado) async {
    try {
      final List<Evento> eventos = await obtenerEventos();
      final int index = eventos.indexWhere((e) => e.id == eventoActualizado.id);
      
      if (index != -1) {
        eventos[index] = eventoActualizado;
        
        final prefs = await SharedPreferences.getInstance();
        final String eventosJson = json.encode(eventos.map((e) => e.toJson()).toList());
        
        return await prefs.setString(_keyEventos, eventosJson);
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
}