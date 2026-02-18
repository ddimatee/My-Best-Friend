import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AlbumProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  bool _cargando = false;
  bool _sincronizando = false;
  String? _error;

  // Filtros básicos y almacenamiento in-memory
  final Map<String, List<Map<String, dynamic>>> _fotosPorMascota = {}; // mascotaId -> fotos

  bool get cargando => _cargando;
  bool get sincronizando => _sincronizando;
  String? get error => _error;

  List<Map<String, dynamic>> fotos(String mascotaId) => List.unmodifiable(_fotosPorMascota[mascotaId] ?? const []);

  Map<String, dynamic> _normalizarFoto(Map<String, dynamic> foto) {
    final id = (foto['_id'] ?? foto['id'])?.toString();
    final mascota = foto['mascota'];
    final mascotaId = (foto['mascotaId'] ??
            (mascota is Map ? mascota['_id'] ?? mascota['id'] : mascota))
        ?.toString();

    final out = Map<String, dynamic>.from(foto);
    if (id != null) {
      out['_id'] = id;
      out['id'] = id;
    }
    if (mascotaId != null) out['mascotaId'] = mascotaId;
    return out;
  }

  Future<void> cargar({String? mascotaId, bool forzar = false}) async {
    if (_cargando) return;
    _setCargando(true); _setError(null);
    final resp = await _api.obtenerFotos(mascotaId: mascotaId, limite: 100); // carga inicial
    if (resp['success']) {
      final data = resp['data'];
      final List<dynamic> lista = (data is List)
          ? data
          : ((data is Map && data['fotos'] is List) ? data['fotos'] as List : const []);
      final cast = lista
          .whereType<Map>()
          .map((f) => _normalizarFoto(Map<String, dynamic>.from(f)))
          .toList();
      if (mascotaId != null) {
        _fotosPorMascota[mascotaId] = cast;
      } else {
        // distribuir por mascota
        _fotosPorMascota.clear();
        for (final f in cast) {
          final mid = (f['mascotaId'] ??
                  ((f['mascota'] is Map) ? f['mascota']['_id'] ?? f['mascota']['id'] : f['mascota']))
              ?.toString();
          if (mid != null && mid.isNotEmpty) {
            _fotosPorMascota.putIfAbsent(mid, () => []).add(f);
          }
        }
      }
      notifyListeners();
    } else {
      _setError(resp['message']);
    }
    _setCargando(false);
  }

  Future<bool> subir({
    required String mascotaId,
    required String url,
    String? titulo,
    String? descripcion,
    List<String>? etiquetas,
    bool esPortada = false,
    DateTime? fecha,
  }) async {
    _setSincronizando(true);
    final resp = await _api.subirFoto(
      mascotaId: mascotaId,
      url: url,
      titulo: titulo,
      descripcion: descripcion,
      etiquetas: etiquetas,
      esPortada: esPortada,
      fecha: fecha,
    );
    if (resp['success']) {
      final foto = resp['data']['foto'] ?? resp['data'];
      if (foto is Map<String, dynamic>) {
        final normalizada = _normalizarFoto(foto);
        final mid = (normalizada['mascotaId'] ?? mascotaId).toString();
        _fotosPorMascota.putIfAbsent(mid, () => []).insert(0, normalizada);
        // Si es portada, desmarcar otras localmente
        if (normalizada['esPortada'] == true) {
          for (final f in _fotosPorMascota[mid]!) {
            if (f['_id'] != normalizada['_id']) f['esPortada'] = false;
          }
        }
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

  Future<bool> actualizar(String fotoId, Map<String, dynamic> cambios) async {
    _setSincronizando(true);
    final resp = await _api.actualizarFoto(
      fotoId: fotoId,
      titulo: cambios['titulo'],
      descripcion: cambios['descripcion'],
      etiquetas: cambios['etiquetas'] == null ? null : List<String>.from(cambios['etiquetas']),
      esPortada: cambios['esPortada'],
    );
    if (resp['success']) {
      final foto = resp['data']['foto'] ?? resp['data'];
      if (foto is Map<String, dynamic>) {
        _replace(fotoId, _normalizarFoto(foto));
      }
      _setSincronizando(false);
      return true;
    } else {
      _setError(resp['message']);
      _setSincronizando(false);
      return false;
    }
  }

  Future<bool> eliminar(String fotoId) async {
    _setSincronizando(true);
    final resp = await _api.eliminarFoto(fotoId);
    if (resp['success']) {
      for (final lista in _fotosPorMascota.values) {
        lista.removeWhere((f) => (f['_id']?.toString() == fotoId || f['id']?.toString() == fotoId));
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

  void _replace(String id, Map<String, dynamic> nueva) {
    for (final lista in _fotosPorMascota.values) {
      final idx = lista.indexWhere((f) => (f['_id']?.toString() == id || f['id']?.toString() == id));
      if (idx != -1) {
        final mascotaId = (nueva['mascotaId'] ??
                ((lista[idx]['mascota'] is Map)
                    ? (lista[idx]['mascota']['_id'] ?? lista[idx]['mascota']['id'])
                    : lista[idx]['mascota']))
            ?.toString();
        lista[idx] = nueva;
        if (nueva['esPortada'] == true && mascotaId != null) {
          // desmarcar otras
            for (final f in _fotosPorMascota[mascotaId] ?? []) {
              if (f['_id'] != id) f['esPortada'] = false;
            }
        }
        notifyListeners();
        return;
      }
    }
  }

  void clear() {
    _fotosPorMascota.clear();
    _error = null;
    _cargando = false;
    _sincronizando = false;
    notifyListeners();
  }

  void _setCargando(bool v) { _cargando = v; notifyListeners(); }
  void _setSincronizando(bool v) { _sincronizando = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }
}
