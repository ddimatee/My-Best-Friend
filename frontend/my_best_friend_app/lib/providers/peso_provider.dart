import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class PesoProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  bool _cargando = false;
  bool _sincronizando = false;
  String? _error;

  // mascotaId -> lista ordenada por fecha desc
  final Map<String, List<Map<String, dynamic>>> _registros = {};

  bool get cargando => _cargando;
  bool get sincronizando => _sincronizando;
  String? get error => _error;

  List<Map<String, dynamic>> registros(String mascotaId) => List.unmodifiable(_registros[mascotaId] ?? const []);

  Future<void> cargar({String? mascotaId, bool forzar = false}) async {
    if (_cargando) return;
    _setCargando(true); _setError(null);
    final resp = await _api.obtenerRegistrosPeso(mascotaId: mascotaId);
    if (resp['success']) {
      final lista = (resp['data'] as List).cast<Map<String, dynamic>>();
      if (mascotaId != null) {
        _registros[mascotaId] = lista;
      } else {
        // distribuir
        _registros.clear();
        for (final r in lista) {
          final mid = (r['mascota'] is Map) ? r['mascota']['_id'] : r['mascota'];
          if (mid != null) {
            _registros.putIfAbsent(mid, () => []).add(r);
          }
        }
      }
      notifyListeners();
    } else {
      _setError(resp['message']);
    }
    _setCargando(false);
  }

  Future<bool> crear({
    required String mascotaId,
    required double peso,
    DateTime? fecha,
    String? observaciones,
    String tipoRegistro = 'rutina',
  }) async {
    _setSincronizando(true);
    final resp = await _api.crearRegistroPeso(
      mascotaId: mascotaId,
      peso: peso,
      fecha: fecha,
      observaciones: observaciones,
      tipoRegistro: tipoRegistro,
    );
    if (resp['success']) {
      final reg = resp['data']['registro'] ?? resp['data'];
      if (reg is Map<String, dynamic>) {
        _registros.putIfAbsent(mascotaId, () => []).insert(0, reg); // más reciente al inicio
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

  Future<bool> actualizar(String registroId, Map<String, dynamic> cambios) async {
    _setSincronizando(true);
    final resp = await _api.actualizarRegistroPeso(
      registroId: registroId,
      peso: cambios['peso'],
      fecha: cambios['fecha'],
      observaciones: cambios['observaciones'],
      tipoRegistro: cambios['tipoRegistro'],
    );
    if (resp['success']) {
      _replace(registroId, resp['data']['registro'] ?? resp['data']);
      _setSincronizando(false);
      return true;
    } else {
      _setError(resp['message']);
      _setSincronizando(false);
      return false;
    }
  }

  Future<bool> eliminar(String registroId) async {
    _setSincronizando(true);
    final resp = await _api.eliminarRegistroPeso(registroId);
    if (resp['success']) {
      for (final lista in _registros.values) {
        lista.removeWhere((r) => r['_id'] == registroId);
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

  void _replace(String id, Map<String, dynamic> nuevo) {
    for (final lista in _registros.values) {
      final idx = lista.indexWhere((r) => r['_id'] == id);
      if (idx != -1) {
        lista[idx] = nuevo;
        notifyListeners();
        return;
      }
    }
  }

  void clear() {
    _registros.clear();
    _error = null;
    _cargando = false;
    _sincronizando = false;
    notifyListeners();
  }

  void _setCargando(bool v) { _cargando = v; notifyListeners(); }
  void _setSincronizando(bool v) { _sincronizando = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }
}
