class Vacuna {
  final String id;
  final String nombre;
  final DateTime fechaAplicacion;
  final String descripcion;
  final String ubicacion;
  final bool tieneRecordatorio;

  Vacuna({
    required this.id,
    required this.nombre,
    required this.fechaAplicacion,
    required this.descripcion,
    required this.ubicacion,
    required this.tieneRecordatorio,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'fechaAplicacion': fechaAplicacion.toIso8601String(),
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'tieneRecordatorio': tieneRecordatorio,
    };
  }

  factory Vacuna.fromJson(Map<String, dynamic> json) {
    return Vacuna(
      id: json['id'],
      nombre: json['nombre'],
      fechaAplicacion: DateTime.parse(json['fechaAplicacion']),
      descripcion: json['descripcion'],
      ubicacion: json['ubicacion'],
      tieneRecordatorio: json['tieneRecordatorio'] ?? false,
    );
  }
}