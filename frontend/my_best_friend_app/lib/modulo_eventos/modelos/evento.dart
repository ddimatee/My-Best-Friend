class Evento {
  final String id;
  final String titulo;
  final String categoria;
  final DateTime fecha;
  final String descripcion;
  final bool tieneRecordatorio;

  Evento({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.fecha,
    required this.descripcion,
    required this.tieneRecordatorio,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'categoria': categoria,
      'fecha': fecha.toIso8601String(),
      'descripcion': descripcion,
      'tieneRecordatorio': tieneRecordatorio,
    };
  }

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'],
      titulo: json['titulo'],
      categoria: json['categoria'],
      fecha: DateTime.parse(json['fecha']),
      descripcion: json['descripcion'],
      tieneRecordatorio: json['tieneRecordatorio'] ?? false,
    );
  }
}