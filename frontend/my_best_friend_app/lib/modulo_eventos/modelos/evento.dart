class Evento {
  final String id;
  final String titulo;
  final String categoria; // En backend es 'tipo'
  final DateTime fecha;
  final String? hora;
  final String? descripcion;
  final bool? completado;
  final String? prioridad;
  final Map<String, dynamic>? recordatorio;
  final Map<String, dynamic>? mascota;

  Evento({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.fecha,
    this.hora,
    this.descripcion,
    this.completado,
    this.prioridad,
    this.recordatorio,
    this.mascota,
  });

  bool get tieneRecordatorio => recordatorio?['activo'] == true;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'titulo': titulo,
      'tipo': categoria,
      'categoria': categoria,
      'fecha': fecha.toIso8601String(),
      'hora': hora,
      'descripcion': descripcion,
      'completado': completado,
      'prioridad': prioridad,
      'recordatorio': recordatorio,
      'mascota': mascota,
    };
  }

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: (json['_id'] ?? json['id']).toString(),
      titulo: (json['titulo'] ?? '').toString(),
      categoria: (json['tipo'] ?? json['categoria'] ?? 'otro').toString(),
      fecha: DateTime.parse(json['fecha'].toString()),
      hora: json['hora']?.toString(),
      descripcion: json['descripcion']?.toString(),
      completado: json['completado'] as bool?,
      prioridad: json['prioridad']?.toString(),
      recordatorio: json['recordatorio'] is Map ? Map<String, dynamic>.from(json['recordatorio']) : null,
      mascota: json['mascota'] is Map ? Map<String, dynamic>.from(json['mascota']) : null,
    );
  }
}