import '../modelos/evento.dart';
import '../../services/api_service.dart';

class EventoService {
  static final ApiService _api = ApiService();

  // Obtener todos los eventos
  static Future<List<Evento>> obtenerEventos() async {
    try {
      final resp = await _api.obtenerEventos();
      if (resp['success'] == true && resp['data'] is List) {
        final lista = resp['data'] as List;
        return lista.map((json) => Evento.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener eventos: $e');
      return [];
    }
  }

  // Guardar un nuevo evento (ya no se usa, se usa EventosProvider)
  static Future<bool> guardarEvento(Evento evento) async {
    // Deprecated: usar EventosProvider.crear()
    return false;
  }

  // Eliminar un evento (ya no se usa, se usa EventosProvider)
  static Future<bool> eliminarEvento(String id) async {
    // Deprecated: usar EventosProvider.eliminar()
    return false;
  }

  // Actualizar un evento existente (ya no se usa, se usa EventosProvider)
  static Future<bool> actualizarEvento(Evento eventoActualizado) async {
    // Deprecated: usar EventosProvider.actualizar()
    return false;
  }
}