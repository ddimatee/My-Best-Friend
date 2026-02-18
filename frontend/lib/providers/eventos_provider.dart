import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class EventosProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  bool _cargando = false;
  bool _sincronizando = false;
  String? _error;

  // Agrupación básica: fecha (yyyy-MM-dd) -> lista de eventos
  Map<String, List<Map<String, dynamic>>> _eventosPorDia = {};
  // Cache de todos los eventos (para pantalla "todos")
  List<Map<String, dynamic>> _todosEventos = [];
  DateTime? _ultimaCargaTodos;

  bool get cargando => _cargando;
  bool get sincronizando => _sincronizando;
  String? get error => _error;

  List<Map<String, dynamic>> eventosDeDia(String dayKey) {
    final eventos = _eventosPorDia[dayKey];
    if (eventos == null) return [];
    return List.unmodifiable(eventos);
  }

  List<Map<String,dynamic>> get todosEventos => List.unmodifiable(_todosEventos);

  Future<void> cargarDia(DateTime fecha, {String? mascotaId, bool forzar = false}) async {
    final key = _key(fecha);
    print('🔄 EventosProvider.cargarDia - fecha: $key, mascota: $mascotaId, forzar: $forzar');
    
    // Si no es forzar y ya tenemos los datos, no recargar
    if (!forzar) {
      final existing = _eventosPorDia[key];
      if (existing != null) {
        print('ℹ️ Ya hay ${existing.length} eventos en caché para esta fecha');
        return;
      }
    }
    
    _setCargando(true); 
    _setError(null);
    print('📡 Llamando API.obtenerEventos...');
    
    try {
      final resp = await _api.obtenerEventos(
        fechaISO: key,
        mascotaId: mascotaId,
      );
      print('📬 Respuesta recibida - success: ${resp['success']}');
      
      if (resp['success']) {
        final data = resp['data'];
        if (data is List) {
          final listaBase = data.cast<Map<String, dynamic>>();
          final lista = (mascotaId == null)
              ? listaBase
              : listaBase.where((ev) {
                  final mid = (ev['mascotaId'] ??
                          ((ev['mascota'] is Map)
                              ? (ev['mascota']['_id'] ?? ev['mascota']['id'])
                              : ev['mascota']))
                      ?.toString();
                  return mid == mascotaId;
                }).toList();
          print('✅ Eventos obtenidos: ${lista.length}');
          _eventosPorDia[key] = lista;
          notifyListeners();
        } else {
          print('⚠️ Data no es una lista: ${data.runtimeType}');
          _eventosPorDia[key] = [];
          notifyListeners();
        }
      } else {
        print('❌ Error en respuesta: ${resp['message']}');
        _setError(resp['message'] ?? 'Error desconocido');
        _eventosPorDia[key] = [];
        notifyListeners();
      }
    } catch (e, stackTrace) {
      print('💥 Excepción al cargar eventos: $e');
      print('Stack trace: $stackTrace');
      _setError(e.toString());
      _eventosPorDia[key] = [];
      notifyListeners();
    } finally {
      _setCargando(false);
      print('🏁 cargarDia finalizado para $key');
    }
  }

  // Cargar TODOS los eventos del usuario (opcionalmente filtrando por mascota)
  Future<void> cargarTodos({String? mascotaId, bool forzar = false}) async {
    // Evitar recarga si cache reciente (< 1 minuto) y no se fuerza
    if (!forzar && _todosEventos.isNotEmpty && _ultimaCargaTodos != null && DateTime.now().difference(_ultimaCargaTodos!).inSeconds < 60) {
      return;
    }
    _setCargando(true);
    _setError(null);
    try {
      final resp = await _api.obtenerEventos(mascotaId: mascotaId);
      if (resp['success']) {
        final data = resp['data'];
        if (data is List) {
          final listaBase = data.cast<Map<String,dynamic>>();
          final lista = (mascotaId == null)
              ? listaBase
              : listaBase.where((ev) {
                  final mid = (ev['mascotaId'] ??
                          ((ev['mascota'] is Map)
                              ? (ev['mascota']['_id'] ?? ev['mascota']['id'])
                              : ev['mascota']))
                      ?.toString();
                  return mid == mascotaId;
                }).toList();
          // Ordenar por fecha + hora
            lista.sort((a,b){
              DateTime fa = DateTime.tryParse(a['fecha']?.toString() ?? '') ?? DateTime.now();
              DateTime fb = DateTime.tryParse(b['fecha']?.toString() ?? '') ?? DateTime.now();
              int cmp = fa.compareTo(fb);
              if (cmp != 0) return cmp;
              final ha = a['hora']?.toString() ?? '';
              final hb = b['hora']?.toString() ?? '';
              return ha.compareTo(hb);
            });
          _todosEventos = lista;
          _ultimaCargaTodos = DateTime.now();
          // Rellenar mapa por día para reutilización
          _eventosPorDia.clear();
          for (final ev in lista) {
            final fechaStr = ev['fecha'].toString().split('T')[0];
            _eventosPorDia.putIfAbsent(fechaStr, () => []).add(ev);
          }
          notifyListeners();
        } else {
          _todosEventos = [];
          _ultimaCargaTodos = DateTime.now();
          notifyListeners();
        }
      } else {
        _setError(resp['message'] ?? 'Error al cargar eventos');
        _todosEventos = [];
        _ultimaCargaTodos = DateTime.now();
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      _todosEventos = [];
      _ultimaCargaTodos = DateTime.now();
      notifyListeners();
    } finally {
      _setCargando(false);
    }
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
        // Parsear fecha - el backend guarda solo la fecha (YYYY-MM-DD)
        // pero al devolverla MongoDB la convierte a ISO con T00:00:00.000Z
        // Extraemos solo la parte de la fecha para la clave
        final fechaStr = ev['fecha'].toString().split('T')[0]; // "2025-09-30"
        final key = fechaStr;
        _eventosPorDia.putIfAbsent(key, () => []).add(ev);
        // Actualizar cache de todos (insertar manteniendo orden)
        _todosEventos.add(ev);
        _todosEventos.sort((a,b){
          DateTime fa = DateTime.tryParse(a['fecha']?.toString() ?? '') ?? DateTime.now();
          DateTime fb = DateTime.tryParse(b['fecha']?.toString() ?? '') ?? DateTime.now();
          int cmp = fa.compareTo(fb);
          if (cmp != 0) return cmp;
          return (a['hora']??'').toString().compareTo((b['hora']??'').toString());
        });
        notifyListeners();
        // Programar notificación si aplica
        try {
          if (recordatorioActivo) {
            final fechaCompleta = DateTime.parse(ev['fecha']);
            final id = (ev['_id'] ?? ev['id']).toString();
            await NotificationService().scheduleEventReminder(
              eventoId: id,
              fechaEvento: fechaCompleta,
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
    if (eventoId.isEmpty) {
      _setError('ID del evento no válido');
      return false;
    }
    _setSincronizando(true);
    _setError(null);
    try {
      final resp = await _api.eliminarEvento(eventoId);
      if (resp['success'] == true) {
        // Eliminar de todas las listas en memoria
        for (final lista in _eventosPorDia.values) {
          lista.removeWhere((e) {
            final id = (e['_id'] ?? e['id']).toString();
            return id == eventoId;
          });
        }
        notifyListeners();
        // Cancelar notificación
        try { 
          await NotificationService().cancelEventReminder(eventoId); 
        } catch (e) {
          print('Error al cancelar notificación: $e');
        }
        _setSincronizando(false);
        return true;
      } else {
        final errorMsg = resp['message'] ?? resp['error'] ?? 'Error desconocido al eliminar evento';
        _setError(errorMsg);
        _setSincronizando(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
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
        // Extraer solo la parte de fecha YYYY-MM-DD para la clave
        final fechaStr = nuevo['fecha'].toString().split('T')[0];
        final keyNuevo = fechaStr;
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
