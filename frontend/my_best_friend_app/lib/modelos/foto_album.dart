class FotoAlbum {
  final String id;
  final String mes;
  final String ano;
  final List<String> rutasImagenes; // Cambiado de String? a List<String>
  final String? descripcion;
  final DateTime fechaSubida;

  FotoAlbum({
    required this.id,
    required this.mes,
    required this.ano,
    List<String>? rutasImagenes,
    this.descripcion,
    required this.fechaSubida,
  }) : rutasImagenes = rutasImagenes ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mes': mes,
      'ano': ano,
      'rutasImagenes': rutasImagenes.where((ruta) => ruta.isNotEmpty).toList(),
      'descripcion': descripcion,
      'fechaSubida': fechaSubida.toIso8601String(),
    };
  }

  factory FotoAlbum.fromJson(Map<String, dynamic> json) {
    List<String> rutasSeguras = [];
    
    // Manejar tanto el formato antiguo como el nuevo
    if (json['rutasImagenes'] != null) {
      // Nuevo formato con lista de imágenes
      final dynamic rutasData = json['rutasImagenes'];
      if (rutasData is List) {
        rutasSeguras = rutasData
            .where((item) => item != null && item.toString().isNotEmpty)
            .map((item) => item.toString())
            .toList();
      }
    } else if (json['rutaImagen'] != null && json['rutaImagen'].toString().isNotEmpty) {
      // Formato antiguo con una sola imagen - migrar
      rutasSeguras = [json['rutaImagen'].toString()];
    }
    
    return FotoAlbum(
      id: json['id']?.toString() ?? '',
      mes: json['mes']?.toString() ?? '',
      ano: json['ano']?.toString() ?? '',
      rutasImagenes: rutasSeguras,
      descripcion: json['descripcion']?.toString(),
      fechaSubida: DateTime.tryParse(json['fechaSubida']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  FotoAlbum copyWith({
    String? id,
    String? mes,
    String? ano,
    List<String>? rutasImagenes,
    String? descripcion,
    DateTime? fechaSubida,
  }) {
    return FotoAlbum(
      id: id ?? this.id,
      mes: mes ?? this.mes,
      ano: ano ?? this.ano,
      rutasImagenes: rutasImagenes ?? this.rutasImagenes,
      descripcion: descripcion ?? this.descripcion,
      fechaSubida: fechaSubida ?? this.fechaSubida,
    );
  }

  bool get tieneImagenes => rutasImagenes.isNotEmpty;
  int get cantidadImagenes => rutasImagenes.length;
  
  // Método para agregar una imagen
  FotoAlbum agregarImagen(String rutaImagen) {
    if (rutaImagen.isNotEmpty && rutasImagenes.length < 4 && !rutasImagenes.contains(rutaImagen)) {
      final nuevasRutas = List<String>.from(rutasImagenes);
      nuevasRutas.add(rutaImagen);
      return copyWith(rutasImagenes: nuevasRutas);
    }
    return this; // No agregar si ya hay 4, está vacía o ya existe
  }
  
  // Método para obtener imagen en posición específica
  String? obtenerImagen(int indice) {
    if (indice >= 0 && indice < rutasImagenes.length) {
      return rutasImagenes[indice];
    }
    return null;
  }
}