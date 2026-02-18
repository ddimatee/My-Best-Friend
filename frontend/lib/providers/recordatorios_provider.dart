import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../modulo_calendario/modelos/evento_calendario.dart';
import '../modulo_calendario/servicios/calendario_service.dart';

class RecordatoriosProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  bool _sincronizando = false;
  bool get sincronizando => _sincronizando;
  String? _error; String? get error => _error;

  void _setSync(bool v){ _sincronizando = v; notifyListeners(); }
  void _setError(String? e){ _error = e; notifyListeners(); }

  // Sincroniza: sube los locales nuevos y descarga backend
  Future<void> sincronizar({required String userId}) async {
    if (_sincronizando) return; _setSync(true); _setError(null);
    try {
      // Cargar locales filtrados por userId
      final locales = await CalendarioService.obtenerEventos(currentUserId: userId);
      // Subir cada uno si no existe en backend (heurística: no tienen _id backend todavía)
      for (final ev in locales) {
        final mascotaId = ev.mascotaId?.toString();
        if (mascotaId == null || mascotaId.isEmpty) {
          continue;
        }
        // Para simplificar: siempre crear (el backend generará uno nuevo). Se podría mejorar con mapeo local-backend.
        try {
          await _api.crearRecordatorioBackend(
            titulo: ev.titulo,
            descripcion: ev.descripcion,
            categoria: ev.categoria,
            fechaHora: ev.fechaHora,
            tipoRecordatorio: ev.tipoRecordatorio,
            frecuencia: ev.frecuencia,
            avisos: ev.avisos.map((a)=>{
              'tipo': a.tipo,
              'minutos': a.minutos,
              'descripcion': a.descripcion,
            }).toList(),
            mascotaId: mascotaId,
            mascotaNombre: ev.mascotaNombre,
            userId: userId,
            activo: ev.activo,
          );
        } catch(_) {}
      }
      // Descargar backend y re-escribir los locales solo con backend + userId
      final resp = await _api.listarRecordatoriosBackend();
      if (resp['success']) {
        final data = resp['data'] as List? ?? [];
        final converted = data
            .whereType<Map>()
            .map((raw) => Map<String, dynamic>.from(raw))
            .where((r) {
              final mascotaId = r['mascotaId']?.toString();
              return mascotaId != null && mascotaId.isNotEmpty;
            })
            .map((r){
              return EventoCalendario(
                id: r['_id'] ?? r['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                titulo: r['titulo'] ?? '',
                descripcion: r['descripcion'] ?? '',
                categoria: r['categoria'] ?? 'otro',
                fechaHora: DateTime.tryParse(r['fechaHora'] ?? '') ?? DateTime.now(),
                tipoRecordatorio: r['tipoRecordatorio'] ?? 'una_vez',
                frecuencia: r['frecuencia'] ?? 'una_vez',
                avisos: ((r['avisos'] as List?) ?? []).map((av)=>TipoAviso(
                  tipo: av['tipo'] ?? 'a_la_hora',
                  minutos: av['minutos'] ?? 0,
                  descripcion: av['descripcion'] ?? '',
                )).toList(),
                activo: r['activo'] == false ? false : true,
                userId: userId,
                mascotaId: r['mascotaId']?.toString(),
                mascotaNombre: r['mascotaNombre']?.toString(),
                mascotaFoto: r['mascotaFoto']?.toString(),
              );
            }).toList();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'eventos_calendario_guardados',
          json.encode(converted.map((e) => e.toJson()).toList()),
        );
      } else {
        _setError(resp['message'] ?? 'Error al sincronizar');
      }
    } catch(e){
      _setError(e.toString());
    } finally { _setSync(false); }
  }
}