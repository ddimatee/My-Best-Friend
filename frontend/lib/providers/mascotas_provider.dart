import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class MascotasProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  bool _cargando = false;
  bool _sincronizando = false;
  String? _error;
  final List<Map<String, dynamic>> _mascotas = [];
  DateTime? _ultimaCarga;
  String? _cacheToken;

  bool get cargando => _cargando;
  bool get sincronizando => _sincronizando;
  String? get error => _error;
  List<Map<String, dynamic>> get mascotas => List.unmodifiable(_mascotas);
  DateTime? get ultimaCarga => _ultimaCarga;

  Future<void> cargarMascotas({bool forzar = false}) async {
    final tokenActual = await _api.getToken();
    if (tokenActual == null || tokenActual != _cacheToken) {
      _mascotas.clear();
      _ultimaCarga = null;
      _cacheToken = tokenActual;
    }

    if (_cargando) return;
    if (!forzar && _mascotas.isNotEmpty && _ultimaCarga != null && DateTime.now().difference(_ultimaCarga!).inMinutes < 5) {
      return; // cache fresca
    }
    _setCargando(true);
    _setError(null);
    final resp = await _api.obtenerMascotas();
    if (resp['success']) {
      _mascotas
        ..clear()
        ..addAll((resp['data'] as List).cast<Map<String, dynamic>>());
      _cacheToken = tokenActual;
      if (kDebugMode) {
        // ignore: avoid_print
        print('🐕 Mascotas recibidas (${_mascotas.length}): ' + _mascotas.map((m)=>'${m['_id']}:${m['nombre']}').join(', '));
      }
      _ultimaCarga = DateTime.now();
    } else {
      _setError(resp['message'] ?? 'Error al cargar mascotas');
    }
    _setCargando(false);
  }

  Future<bool> crearMascota(Map<String, dynamic> data) async {
    _setSincronizando(true);
    final resp = await _api.crearMascota(
      nombre: data['nombre'],
      especie: data['especie'],
      raza: data['raza'],
      fechaNacimiento: data['fechaNacimiento'],
      sexo: data['sexo'],
      descripcion: data['descripcion'],
    );
    if (resp['success']) {
      // El backend devuelve {mensaje, mascota}
      final mascota = resp['data']['mascota'] ?? resp['data'];
      if (mascota is Map<String, dynamic>) {
        _mascotas.add(mascota);
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

  Future<bool> actualizarMascota(String id, Map<String,dynamic> data) async {
    _setSincronizando(true);
    final resp = await _api.actualizarMascota(id: id, data: data);
    if (resp['success']) {
      final idx = _mascotas.indexWhere((m) => m['_id'] == id || m['id'] == id);
      if (idx != -1) {
        final updated = resp['data']['mascota'] ?? resp['data'];
        if (updated is Map<String,dynamic>) {
          _mascotas[idx] = updated;
        }
      }
      _setSincronizando(false);
      notifyListeners();
      return true;
    } else {
      _setError(resp['message']);
      _setSincronizando(false);
      return false;
    }
  }

  Future<bool> toggleOculto(String id) async {
    final mascota = buscarPorId(id);
    if (mascota == null) return false;
    final nuevoEstado = !(mascota['oculto'] == true);
    final ok = await actualizarMascota(id, {'oculto': nuevoEstado});
    return ok;
  }

  Future<bool> actualizarFotoPerfil(String id, String url) async {
    return actualizarMascota(id, {'fotoPerfil': url});
  }

  Future<bool> subirFoto(String id, String path) async {
    _setSincronizando(true);
    final resp = await _api.subirFotoMascota(id: id, filePath: path);
    if (resp['success']) {
      final mascota = resp['data']['mascota'] ?? resp['data'];
      if (mascota is Map<String,dynamic>) {
        final idx = _mascotas.indexWhere((m) => m['_id'] == id || m['id'] == id);
        if (idx != -1) {
          _mascotas[idx] = mascota;
          notifyListeners();
        }
      }
      _setSincronizando(false);
      return true;
    } else {
      _setError(resp['message']);
      _setSincronizando(false);
      return false;
    }
  }

  Future<bool> eliminarMascota(String id) async {
    _setSincronizando(true);
    final resp = await _api.eliminarMascota(id);
    if (resp['success']) {
      _mascotas.removeWhere((m) => m['_id'] == id || m['id'] == id);
      _setSincronizando(false);
      notifyListeners();
      return true;
    } else {
      _setError(resp['message']);
      _setSincronizando(false);
      return false;
    }
  }

  void clear() {
    _mascotas.clear();
    _ultimaCarga = null;
    _cacheToken = null;
    _error = null;
    notifyListeners();
  }

  Map<String, dynamic>? buscarPorId(String id) {
    try {
      return _mascotas.firstWhere((m) => m['_id'] == id);
    } catch (_) {
      return null;
    }
  }

  void _setCargando(bool v) { _cargando = v; notifyListeners(); }
  void _setSincronizando(bool v) { _sincronizando = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }
}
