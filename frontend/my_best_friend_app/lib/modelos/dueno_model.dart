class DuenoModel {
  final String id;
  final String nombre;
  final String apellido;
  final String telefono;
  final String email;
  final String direccion;
  final String? fotoPerfil;
  final DateTime fechaCreacion;

  DuenoModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.email,
    required this.direccion,
    this.fotoPerfil,
    required this.fechaCreacion,
  });

  String get nombreCompleto => '$nombre $apellido';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'fotoPerfil': fotoPerfil,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory DuenoModel.fromJson(Map<String, dynamic> json) {
    return DuenoModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      fotoPerfil: json['fotoPerfil']?.toString(),
      fechaCreacion: DateTime.tryParse(json['fechaCreacion']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  DuenoModel copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? telefono,
    String? email,
    String? direccion,
    String? fotoPerfil,
    DateTime? fechaCreacion,
  }) {
    return DuenoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  bool get tieneFotoPerfil => fotoPerfil != null && fotoPerfil!.isNotEmpty;
}