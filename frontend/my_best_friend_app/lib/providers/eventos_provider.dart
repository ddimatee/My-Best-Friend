import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class EventosProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  bool _cargando = false;
  bool _sincronizando = false;
  String? _error;

  // Agrupación básica: fecha (yyyy-MM-dd) -> lista de eventos
  final Map<String, List<Map<String, dynamic>>> _eventosPorDia = {};

  bool get cargando => _cargando;
  bool get sincronizando => _sincronizando;
  String? get error => _error;

  List<Map<String, dynamic>> eventosDeDia(String dayKey) => List.unmodifiable(_eventosPorDia[dayKey] ?? const []);

  Future<void> cargarDia(DateTime fecha, {String? mascotaId, bool forzar = false}) async {
    final key = _key(fecha);
    if (_cargando) return;
    if (!forzar && _eventosPorDia.containsKey(key)) return;
    _setCargando(true); _setError(null);
    final resp = await _api.obtenerEventos(
      fechaISO: key,
      mascotaId: mascotaId,
    );
    if (resp['success']) {
      final lista = (resp['data'] as List).cast<Map<String, dynamic>>();
      _eventosPorDia[key] = lista;
      notifyListeners();
    } else {
      _setError(resp['message']);
    }
    _setCargando(false);
  }

  Future<bool> crear({
    required String mascotaId,
    required String titulo,
    required String tipo,
    required DateTime fecha,
    required String hora,
    String? descripcion,
    bool recordatorioActivo = true,
    int minutosAntes = 30,
    String prioridad = 'media',
  }) async {
    _setSincronizando(true);
    final tipoCanon = _canonicalTipo(tipo);
    final resp = await _api.crearEvento(
      mascotaId: mascotaId,
      titulo: titulo,
      tipo: tipoCanon,
      fecha: fecha,
      hora: hora,
      descripcion: descripcion,
      recordatorioActivo: recordatorioActivo,
      minutosAntes: minutosAntes,
      prioridad: prioridad,
    );
    if (resp['success']) {
      final ev = resp['data']['evento'] ?? resp['data'];
      if (ev is Map<String, dynamic>) {
        final key = _key(DateTime.parse(ev['fecha']));
        _eventosPorDia.putIfAbsent(key, () => []).add(ev);
        notifyListeners();
        // Programar notificación si aplica
        try {
          if (recordatorioActivo) {
            final fecha = DateTime.parse(ev['fecha']);
            final id = (ev['_id'] ?? ev['id']).toString();
            await NotificationService().scheduleEventReminder(
              eventoId: id,
              fechaEvento: fecha,
              titulo: ev['titulo']?.toString() ?? 'Evento',
              body: '(${ev['tipo'] ?? 'evento'}) próximamente',
              minutosAntes: minutosAntes,
            );
          }
        } catch (_) {}
      }
      _setSincronizando(false);
      return true;
    } else {
      _setError(resp['message']);
      _setSincronizando(false);
      return false;
    }
  }

  Future<bool> actualizar(String eventoId, Map<String, dynamic> cambios) async {
    _setSincronizando(true);
    if (cambios['tipo'] != null) {
      cambios['tipo'] = _canonicalTipo(cambios['tipo']);
    }
    final resp = await _api.actualizarEvento(
      eventoId: eventoId,
      titulo: cambios['titulo'],
      tipo: cambios['tipo'],
      fecha: cambios['fecha'],
      hora: cambios['hora'],
      descripcion: cambios['descripcion'],
      prioridad: cambios['prioridad'],
      completado: cambios['completado'],
      recordatorioActivo: cambios['recordatorioActivo'],
      minutosAntes: cambios['minutosAntes'],
    );
    if (resp['success']) {
      final evento = resp['data']['evento'] ?? resp['data'];
      if (evento is Map<String, dynamic>) {
        _replace(eventoId, evento);
        // Reprogramar / cancelar notificación según cambios
        try {
          final id = (evento['_id'] ?? evento['id']).toString();
            final record = evento['recordatorio'];
          final activo = (record is Map) ? (record['activo'] == true) : (cambios['recordatorioActivo'] == true);
          if (activo) {
            final fecha = DateTime.parse(evento['fecha']);
            final minutos = (record is Map && record['tiempoAntes'] is int)
                ? record['tiempoAntes'] as int
                : (cambios['minutosAntes'] ?? 30);
            await NotificationService().scheduleEventReminder(
              eventoId: id,
              fechaEvento: fecha,
              titulo: evento['titulo']?.toString() ?? 'Evento',
              body: '(${evento['tipo'] ?? 'evento'}) actualizado',
              minutosAntes: minutos,
            );
          } else {
            await NotificationService().cancelEventReminder(id);
          }
        } catch (_) {}
      }
      _setSincronizando(false);
      return true;
    } else {
      _setError(resp['message']);
      _setSincronizando(false);
      return false;
    }
  }

  Future<bool> eliminar(String eventoId) async {
    _setSincronizando(true);
    final resp = await _api.eliminarEvento(eventoId);
    if (resp['success']) {
      for (final lista in _eventosPorDia.values) {
        lista.removeWhere((e) => e['_id'] == eventoId);
      }
      notifyListeners();
      // Cancelar notificación
      try { await NotificationService().cancelEventReminder(eventoId); } catch (_) {}
      _setSincronizando(false);
      return true;
    } else {
      _setError(resp['message']);
      _setSincronizando(false);
      return false;
    }
  }

  void _replace(String id, Map<String, dynamic> nuevo) {
    // evento puede cambiar de día si cambia la fecha
    for (final entry in _eventosPorDia.entries) {
      final idx = entry.value.indexWhere((e) => e['_id'] == id);
      if (idx != -1) {
  entry.value.removeAt(idx);
        final keyNuevo = _key(DateTime.parse(nuevo['fecha']));
        _eventosPorDia.putIfAbsent(keyNuevo, () => []).add(nuevo);
        // Si keyNuevo == entry.key y solo se actualizó -> ya está añadida
        notifyListeners();
        return;
      }
    }
  }

  void clear() {
    _eventosPorDia.clear();
    _error = null;
    _cargando = false;
    _sincronizando = false;
    notifyListeners();
  }

  // Reprogramar recordatorios futuros (ejecutar tras login)
  Future<void> reprogramarRecordatoriosFuturos() async {
    try {
      final ahora = DateTime.now();
      // Cargar rango de próximos 3 días si se requiere un endpoint futuro; por ahora usamos ya cargados
      for (final lista in _eventosPorDia.values) {
        for (final e in lista) {
          final record = e['recordatorio'];
          if (record is Map && record['activo'] == true) {
            try {
              final fecha = DateTime.tryParse(e['fecha']?.toString() ?? '');
              if (fecha == null) continue;
              if (fecha.isBefore(ahora)) continue;
              final minutos = (record['tiempoAntes'] is int) ? record['tiempoAntes'] as int : 30;
              await NotificationService().scheduleEventReminder(
                eventoId: (e['_id'] ?? e['id']).toString(),
                fechaEvento: fecha,
                titulo: (e['titulo'] ?? 'Evento').toString(),
                body: '(${e['tipo'] ?? 'evento'}) próximo',
                minutosAntes: minutos,
              );
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
  }

  String _key(DateTime d) => '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  void _setCargando(bool v) { _cargando = v; notifyListeners(); }
  void _setSincronizando(bool v) { _sincronizando = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }

  // Normaliza el tipo ingresado desde la UI a uno aceptado por el backend
  String _canonicalTipo(String tipo) {
    final s = tipo.toString().toLowerCase().trim();
    if (s.startsWith('comida') || s.startsWith('alimen')) return 'alimentacion';
    if (s.contains('entren') || s.contains('paseo') || s.contains('juego') || s.contains('actividad')) return 'ejercicio';
    if (s.startsWith('ejerc')) return 'ejercicio';
    if (s.startsWith('bañ') || s.startsWith('ban')) return 'baño';
    if (s.startsWith('vet')) return 'veterinario';
    if (s.startsWith('medic')) return 'medicamento';
    if (s.contains('social') || s.contains('descans')) return 'otro';
    const allowed = ['veterinario','alimentacion','ejercicio','medicamento','baño','otro'];
    return allowed.contains(s) ? s : 'otro';
  }
}
