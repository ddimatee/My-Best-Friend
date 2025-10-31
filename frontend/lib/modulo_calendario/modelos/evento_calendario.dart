class EventoCalendario {
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final DateTime fechaHora;
  final String tipoRecordatorio; // "una_vez", "repetir"
  final String frecuencia; // "cada_dia", "cada_semana", "cada_mes", "cada_año"
  final List<TipoAviso> avisos;
  final bool activo;
  final String? userId; // Id del usuario dueño (para aislar datos entre cuentas)
  final String? mascotaId; // Id de la mascota asociada
  final String? mascotaNombre; // Nombre de la mascota para mostrar
  final String? mascotaFoto; // URL/path de la foto de la mascota

  EventoCalendario({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.fechaHora,
    required this.tipoRecordatorio,
    required this.frecuencia,
    required this.avisos,
    this.activo = true,
    this.userId,
    this.mascotaId,
    this.mascotaNombre,
    this.mascotaFoto,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'fechaHora': fechaHora.toIso8601String(),
      'tipoRecordatorio': tipoRecordatorio,
      'frecuencia': frecuencia,
      'avisos': avisos.map((aviso) => aviso.toJson()).toList(),
      'activo': activo,
      if (userId != null) 'userId': userId,
      if (mascotaId != null) 'mascotaId': mascotaId,
      if (mascotaNombre != null) 'mascotaNombre': mascotaNombre,
      if (mascotaFoto != null) 'mascotaFoto': mascotaFoto,
    };
  }

  factory EventoCalendario.fromJson(Map<String, dynamic> json) {
    return EventoCalendario(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      fechaHora: DateTime.parse(json['fechaHora']),
      tipoRecordatorio: json['tipoRecordatorio'],
      frecuencia: json['frecuencia'],
      avisos: (json['avisos'] as List).map((aviso) => TipoAviso.fromJson(aviso)).toList(),
      activo: json['activo'] ?? true,
      userId: json['userId'],
      mascotaId: json['mascotaId'],
      mascotaNombre: json['mascotaNombre'],
      mascotaFoto: json['mascotaFoto'],
    );
  }
}

class TipoAviso {
  final String tipo; // "a_la_hora", "antes_de"
  final int minutos; // 0 para a la hora, 15, 30, etc para antes
  final String descripcion; // "A la hora", "15 minutos antes", etc

  TipoAviso({
    required this.tipo,
    required this.minutos,
    required this.descripcion,
  });

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'minutos': minutos,
      'descripcion': descripcion,
    };
  }

  factory TipoAviso.fromJson(Map<String, dynamic> json) {
    return TipoAviso(
      tipo: json['tipo'],
      minutos: json['minutos'],
      descripcion: json['descripcion'],
    );
  }
}
