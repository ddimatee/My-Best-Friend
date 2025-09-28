import 'package:flutter/foundation.dart';

/// Modelo simple de Mascota almacenado sólo en memoria.
class Mascota {
  Mascota({required this.id, required this.nombre, required this.creado});
  final String id;
  String nombre;
  DateTime creado;
  bool oculto = false;
}

/// Repositorio en memoria (singleton light) para compartir mascotas entre pantallas
/// sin todavía integrar un backend ni provider.
class MascotasRepo extends ChangeNotifier {
  static final MascotasRepo _instancia = MascotasRepo._internal();
  factory MascotasRepo() => _instancia;
  MascotasRepo._internal();

  final List<Mascota> _lista = [];
  List<Mascota> get visibles => _lista.where((m) => !m.oculto).toList();
  List<Mascota> get ocultas => _lista.where((m) => m.oculto).toList();

  void agregar(Mascota m) {
    _lista.add(m);
    notifyListeners();
  }

  void toggleOculto(String id) {
    final m = _lista.firstWhere((e) => e.id == id, orElse: () => throw Exception('Mascota no encontrada'));
    m.oculto = !m.oculto;
    notifyListeners();
  }

  List<Mascota> buscar(String query, {bool incluirOcultas = false}) {
    final q = query.trim().toLowerCase();
    final fuente = incluirOcultas ? _lista : visibles;
    if (q.isEmpty) return fuente;
    return fuente.where((m) => m.nombre.toLowerCase().contains(q)).toList();
  }
}