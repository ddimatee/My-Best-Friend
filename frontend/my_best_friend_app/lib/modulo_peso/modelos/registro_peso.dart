class RegistroPeso {
  final String id;
  final double peso; // Peso en kilogramos (valor exacto)
  final DateTime fecha;
  final String notas;

  RegistroPeso({
    required this.id,
    required this.peso,
    required this.fecha,
    this.notas = '',
  });

  // Crear desde JSON
  factory RegistroPeso.fromJson(Map<String, dynamic> json) {
    return RegistroPeso(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      peso: _parsearPesoFromJson(json),
      fecha: DateTime.parse(json['fecha']),
      notas: json['notas'] ?? '',
    );
  }

  // Parsear peso desde diferentes formatos de JSON
  static double _parsearPesoFromJson(Map<String, dynamic> json) {
    if (json.containsKey('pesoNumerico')) {
      return (json['pesoNumerico'] as num).toDouble();
    } else if (json.containsKey('peso')) {
      return double.tryParse(json['peso'].toString()) ?? 0.0;
    }
    return 0.0;
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peso': formatearPeso(peso),
      'pesoNumerico': peso,
      'fecha': fecha.toIso8601String(),
      'notas': notas,
    };
  }

  // Formatear peso para mostrar (sin decimales innecesarios)
  static String formatearPeso(double peso) {
    if (peso == peso.roundToDouble()) {
      return peso.toInt().toString();
    } else {
      return peso.toStringAsFixed(1);
    }
  }

  // Parsear entrada de texto a peso
  static double parsearEntradaPeso(String input) {
    if (input.isEmpty) return 0.0;
    
    try {
      // Si contiene punto decimal, lo toma como está
      if (input.contains('.')) {
        return double.parse(input);
      } else {
        // Si no tiene punto decimal, lo convierte automáticamente
        if (input.length <= 2) {
          // Números muy pequeños (1-99) se toman como decimales
          return double.parse(input) / 10;
        } else {
          // Números de 3+ dígitos: el último dígito es decimal
          String parteEntera = input.substring(0, input.length - 1);
          String parteDecimal = input.substring(input.length - 1);
          return double.parse('$parteEntera.$parteDecimal');
        }
      }
    } catch (e) {
      return 0.0;
    }
  }

  // Crear copia con modificaciones
  RegistroPeso copyWith({
    String? id,
    double? peso,
    DateTime? fecha,
    String? notas,
  }) {
    return RegistroPeso(
      id: id ?? this.id,
      peso: peso ?? this.peso,
      fecha: fecha ?? this.fecha,
      notas: notas ?? this.notas,
    );
  }

  @override
  String toString() {
    return 'RegistroPeso{id: $id, peso: ${formatearPeso(peso)}kg, fecha: $fecha, notas: "$notas"}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegistroPeso &&
        other.id == id &&
        other.peso == peso &&
        other.fecha == fecha &&
        other.notas == notas;
  }

  @override
  int get hashCode {
    return id.hashCode ^ peso.hashCode ^ fecha.hashCode ^ notas.hashCode;
  }
}