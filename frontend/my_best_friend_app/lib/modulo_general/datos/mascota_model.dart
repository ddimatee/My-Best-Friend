import 'package:flutter/foundation.dart';

/// Modelo simple de Mascota almacenado sólo en memoria.
class Mascota {
  Mascota({
    required this.id, 
    required this.nombre, 
    required this.creado, 
    this.imagenPath,
    this.cumpleanos,
    this.situacion,
    this.sexo,
    this.raza,
    this.seguimiento,
    Set<String>? estiloVida,
    this.coCuidado,
    this.rol,
  }) : _estiloVida = estiloVida;
  final String id;
  String nombre;
  DateTime creado;
  bool oculto = false;
  String? imagenPath; // Ruta de la imagen personalizada
  DateTime? cumpleanos; // Fecha de cumpleaños de la mascota
  String? situacion; // "Acabo de tener un perro" | "Ya conozco bien a mi perro"
  String? sexo; // "Macho" | "Hembra"
  String? raza; // Raza de la mascota
  bool? seguimiento; // Seguimiento de comidas/vacunas
  Set<String>? _estiloVida; // Estilo de vida seleccionado (privado)
  bool? coCuidado; // Si cuida con alguien más
  String? rol; // "Dueño" | "Cuidador"
  
  // Getter público que siempre devuelve un Set válido
  Set<String> get estiloVida => _estiloVida ?? {};
  
  // Setter público para el estilo de vida
  set estiloVida(Set<String> value) => _estiloVida = value;
  
  // Método para calcular la edad en días y meses
  Map<String, int> calcularEdad() {
    if (cumpleanos == null) return {'dias': 0, 'meses': 0};
    
    final ahora = DateTime.now();
    final diferencia = ahora.difference(cumpleanos!);
    final dias = diferencia.inDays;
    final meses = (dias / 30.44).floor(); // Promedio de días por mes
    
    return {'dias': dias, 'meses': meses};
  }
  
  // Método para obtener la edad formateada
  String obtenerEdadFormateada() {
    final edad = calcularEdad();
    final dias = edad['dias']!;
    final meses = edad['meses']!;
    
    if (meses == 0) {
      return '$dias días';
    } else if (meses < 12) {
      return '$dias días ($meses meses)';
    } else {
      final anos = (meses / 12).floor();
      final mesesRestantes = meses % 12;
      if (mesesRestantes == 0) {
        return '$anos ${anos == 1 ? 'año' : 'años'}';
      } else {
        return '$anos ${anos == 1 ? 'año' : 'años'} y $mesesRestantes ${mesesRestantes == 1 ? 'mes' : 'meses'}';
      }
    }
  }
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

  void actualizarImagen(String id, String? imagenPath) {
    final m = _lista.firstWhere((e) => e.id == id, orElse: () => throw Exception('Mascota no encontrada'));
    m.imagenPath = imagenPath;
    notifyListeners();
  }

  void actualizar(String id, {
    String? nombre,
    DateTime? cumpleanos,
    String? situacion,
    String? sexo,
    String? raza,
    bool? seguimiento,
    Set<String>? estiloVida,
    bool? coCuidado,
    String? rol,
  }) {
    final m = _lista.firstWhere((e) => e.id == id, orElse: () => throw Exception('Mascota no encontrada'));
    if (nombre != null) m.nombre = nombre;
    if (cumpleanos != null) m.cumpleanos = cumpleanos;
    if (situacion != null) m.situacion = situacion;
    if (sexo != null) m.sexo = sexo;
    if (raza != null) m.raza = raza;
    if (seguimiento != null) m.seguimiento = seguimiento;
    if (estiloVida != null) m._estiloVida = estiloVida;
    if (coCuidado != null) m.coCuidado = coCuidado;
    if (rol != null) m.rol = rol;
    notifyListeners();
  }

  Mascota? obtener(String id) {
    try {
      return _lista.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  void eliminar(String id) {
    _lista.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  List<Mascota> buscar(String query, {bool incluirOcultas = false}) {
    final q = query.trim().toLowerCase();
    final fuente = incluirOcultas ? _lista : visibles;
    if (q.isEmpty) return fuente;
    return fuente.where((m) => m.nombre.toLowerCase().contains(q)).toList();
  }
}