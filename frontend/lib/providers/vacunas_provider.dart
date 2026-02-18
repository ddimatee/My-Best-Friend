import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VacunasProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  bool _cargando = false;
  bool _sincronizando = false;
  String? _error;
  final Map<String, List<Map<String, dynamic>>> _vacunasPorMascota = {}; // mascotaId -> vacunas

  bool get cargando => _cargando;
  bool get sincronizando => _sincronizando;
  String? get error => _error;

  List<Map<String, dynamic>> vacunasDe(String mascotaId) => List.unmodifiable(_vacunasPorMascota[mascotaId] ?? const []);

  Map<String, dynamic> _normalizarVacuna(Map<String, dynamic> vacuna) {
    final id = (vacuna['_id'] ?? vacuna['id'])?.toString();
    final mascota = vacuna['mascota'];
    final mascotaId = (vacuna['mascotaId'] ??
            (mascota is Map ? mascota['_id'] ?? mascota['id'] : mascota))
        ?.toString();

    final out = Map<String, dynamic>.from(vacuna);
    if (id != null) {
      out['_id'] = id;
      out['id'] = id;
    }
    if (mascotaId != null) {
      out['mascotaId'] = mascotaId;
    }
    return out;
  }
  
  // Obtener todas las vacunas de todas las mascotas
  List<Map<String, dynamic>> todasLasVacunas() {
    final List<Map<String, dynamic>> todas = [];
    for (final lista in _vacunasPorMascota.values) {
      todas.addAll(lista);
    }
    return List.unmodifiable(todas);
  }

  Future<void> cargarVacunas({String? mascotaId, bool forzar = false}) async {
    if (_cargando) return;
    _setCargando(true);
    _setError(null);
    final resp = await _api.obtenerVacunas(mascotaId: mascotaId);
    if (resp['success']) {
      final lista = ((resp['data'] as List?) ?? const [])
          .whereType<Map>()
          .map((v) => _normalizarVacuna(Map<String, dynamic>.from(v)))
          .toList();
      if (mascotaId != null) {
        _vacunasPorMascota[mascotaId] = lista;
      } else {
        // Si no se filtra por mascota, distribuir por mascotaId
        _vacunasPorMascota.clear();
        for (final v in lista) {
          final mid = (v['mascotaId'] ??
                  ((v['mascota'] is Map)
                      ? (v['mascota']['_id'] ?? v['mascota']['id'])
                      : v['mascota']))
              ?.toString();
          if (mid != null && mid.isNotEmpty) {
            _vacunasPorMascota.putIfAbsent(mid, () => []).add(v);
          }
        }
      }
      notifyListeners();
    } else {
      _setError(resp['message']);
    }
    _setCargando(false);
  }

  Future<bool> crearVacuna({
    required String mascotaId,
  required String nombre,
  required DateTime fechaAplicacion,
  DateTime? fechaVencimiento,
  String? observaciones,
  String? ubicacion,
  bool? recordatorio,
  TimeOfDay? horaRecordatorio,
  }) async {
    _setSincronizando(true);
    final resp = await _api.crearVacuna(
      mascotaId: mascotaId,
      nombre: nombre,
      fechaAplicacion: fechaAplicacion,
      fechaVencimiento: fechaVencimiento,
      observaciones: observaciones,
      ubicacion: ubicacion,
      recordatorio: recordatorio,
      horaRecordatorio: horaRecordatorio,
    );
    if (resp['success']) {
      final vacuna = resp['data']['vacuna'] ?? resp['data'];
      if (vacuna is Map<String, dynamic>) {
        final normalizada = _normalizarVacuna(vacuna);
        final mid = (normalizada['mascotaId'] ?? mascotaId).toString();
        _vacunasPorMascota.putIfAbsent(mid, () => []).add(normalizada);
        notifyListeners();
      }
      _setSincronizando(false);
      return true;
    } else {
      _setError(resp['message']);
      _setSincronizando(false);
      return false;
    }
  }

  Future<bool> actualizarVacuna(String vacunaId, Map<String, dynamic> cambios) async {
    _setSincronizando(true);
    final resp = await _api.actualizarVacuna(
      vacunaId: vacunaId,
      mascotaId: cambios['mascotaId'],
      nombre: cambios['nombre'],
      fechaAplicacion: cambios['fechaAplicacion'],
      fechaVencimiento: cambios['fechaVencimiento'],
      observaciones: cambios['observaciones'],
      ubicacion: cambios['ubicacion'],
      recordatorio: cambios['recordatorio'],
      horaRecordatorio: cambios['horaRecordatorio'] as TimeOfDay?,
    );
    if (resp['success']) {
      final vacuna = resp['data']['vacuna'] ?? resp['data'];
      if (vacuna is Map<String, dynamic>) {
        _replace(vacunaId, _normalizarVacuna(vacuna));
      }
      _setSincronizando(false);
      return true;
    } else {
      _setError(resp['message']);
      _setSincronizando(false);
      return false;
    }
  }

  Future<bool> eliminarVacuna(String vacunaId) async {
    _setSincronizando(true);
    final resp = await _api.eliminarVacuna(vacunaId);
    if (resp['success']) {
      for (final lista in _vacunasPorMascota.values) {
        lista.removeWhere((v) => (v['_id']?.toString() == vacunaId || v['id']?.toString() == vacunaId));
      }
      notifyListeners();
      _setSincronizando(false);
      return true;
    } else {
      _setError(resp['message']);
      _setSincronizando(false);
      return false;
    }
  }

  void _replace(String id, Map<String, dynamic> vacuna) {
    String? oldMascotaId;
    for (final entry in _vacunasPorMascota.entries) {
      final idx = entry.value.indexWhere((v) =>
          v['_id']?.toString() == id ||
          v['id']?.toString() == id);
      if (idx != -1) {
        oldMascotaId = entry.key;
        entry.value.removeAt(idx);
        break;
      }
    }

    final newMascotaId = (vacuna['mascotaId'] ??
            ((vacuna['mascota'] is Map)
                ? (vacuna['mascota']['_id'] ?? vacuna['mascota']['id'])
                : vacuna['mascota']))
        ?.toString();

    if (newMascotaId != null && newMascotaId.isNotEmpty) {
      _vacunasPorMascota.putIfAbsent(newMascotaId, () => []).add(vacuna);
    } else if (oldMascotaId != null) {
      _vacunasPorMascota.putIfAbsent(oldMascotaId, () => []).add(vacuna);
    }
    notifyListeners();
  }

  void clear() {
    _vacunasPorMascota.clear();
    _error = null;
    _cargando = false;
    _sincronizando = false;
    notifyListeners();
  }

  void _setCargando(bool v) { _cargando = v; notifyListeners(); }
  void _setSincronizando(bool v) { _sincronizando = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }
}
