import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/registro_peso.dart';

class PesoService {
  static const String _keyRegistros = 'registros_peso';

  // Obtener todos los registros de peso
  static Future<List<RegistroPeso>> obtenerRegistros() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? registrosJson = prefs.getString(_keyRegistros);
      
      if (registrosJson == null || registrosJson.isEmpty) {
        return [];
      }

      final List<dynamic> registrosList = json.decode(registrosJson);
      return registrosList
          .map((json) => RegistroPeso.fromJson(json))
          .toList()
        ..sort((a, b) => b.fecha.compareTo(a.fecha)); // Más recientes primero
    } catch (e) {
      print('Error al obtener registros de peso: $e');
      return [];
    }
  }

  // Guardar un nuevo registro de peso
  static Future<bool> guardarRegistro(RegistroPeso registro) async {
    try {
      final List<RegistroPeso> registros = await obtenerRegistros();
      registros.insert(0, registro); // Agregar al inicio (más reciente)
      
      final String registrosJson = json.encode(
        registros.map((r) => r.toJson()).toList(),
      );
      
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyRegistros, registrosJson);
    } catch (e) {
      print('Error al guardar registro de peso: $e');
      return false;
    }
  }

  // Actualizar un registro existente
  static Future<bool> actualizarRegistro(RegistroPeso registroActualizado) async {
    try {
      final List<RegistroPeso> registros = await obtenerRegistros();
      final int index = registros.indexWhere((r) => r.id == registroActualizado.id);
      
      if (index != -1) {
        registros[index] = registroActualizado;
        
        final String registrosJson = json.encode(
          registros.map((r) => r.toJson()).toList(),
        );
        
        final prefs = await SharedPreferences.getInstance();
        return await prefs.setString(_keyRegistros, registrosJson);
      }
      
      return false;
    } catch (e) {
      print('Error al actualizar registro de peso: $e');
      return false;
    }
  }

  // Eliminar un registro
  static Future<bool> eliminarRegistro(String id) async {
    try {
      final List<RegistroPeso> registros = await obtenerRegistros();
      registros.removeWhere((r) => r.id == id);
      
      final String registrosJson = json.encode(
        registros.map((r) => r.toJson()).toList(),
      );
      
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyRegistros, registrosJson);
    } catch (e) {
      print('Error al eliminar registro de peso: $e');
      return false;
    }
  }

  // Obtener registros filtrados por fecha
  static Future<List<RegistroPeso>> obtenerRegistrosPorFecha({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final List<RegistroPeso> todosLosRegistros = await obtenerRegistros();
    
    if (fechaInicio == null && fechaFin == null) {
      return todosLosRegistros;
    }
    
    return todosLosRegistros.where((registro) {
      if (fechaInicio != null && registro.fecha.isBefore(fechaInicio)) {
        return false;
      }
      if (fechaFin != null && registro.fecha.isAfter(fechaFin)) {
        return false;
      }
      return true;
    }).toList();
  }

  // Obtener registros de hoy
  static Future<List<RegistroPeso>> obtenerRegistrosHoy() async {
    final DateTime ahora = DateTime.now();
    final DateTime inicioDelDia = DateTime(ahora.year, ahora.month, ahora.day);
    final DateTime finDelDia = inicioDelDia.add(const Duration(days: 1));
    
    return obtenerRegistrosPorFecha(
      fechaInicio: inicioDelDia,
      fechaFin: finDelDia,
    );
  }

  // Obtener registros de la última semana
  static Future<List<RegistroPeso>> obtenerRegistrosSemana() async {
    final DateTime ahora = DateTime.now();
    final DateTime haceSemana = ahora.subtract(const Duration(days: 7));
    
    return obtenerRegistrosPorFecha(fechaInicio: haceSemana);
  }

  // Obtener registros del último mes
  static Future<List<RegistroPeso>> obtenerRegistrosMes() async {
    final DateTime ahora = DateTime.now();
    final DateTime haceMes = DateTime(ahora.year, ahora.month - 1, ahora.day);
    
    return obtenerRegistrosPorFecha(fechaInicio: haceMes);
  }

  // Obtener estadísticas básicas
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    final List<RegistroPeso> registros = await obtenerRegistros();
    
    if (registros.isEmpty) {
      return {
        'total': 0,
        'pesoActual': 0.0,
        'pesoMinimo': 0.0,
        'pesoMaximo': 0.0,
        'promedio': 0.0,
      };
    }

    final List<double> pesos = registros.map((r) => r.peso).toList();
    final double pesoActual = registros.first.peso; // El más reciente
    final double pesoMinimo = pesos.reduce((a, b) => a < b ? a : b);
    final double pesoMaximo = pesos.reduce((a, b) => a > b ? a : b);
    final double promedio = pesos.reduce((a, b) => a + b) / pesos.length;

    return {
      'total': registros.length,
      'pesoActual': pesoActual,
      'pesoMinimo': pesoMinimo,
      'pesoMaximo': pesoMaximo,
      'promedio': promedio,
    };
  }

  // Migrar datos existentes al nuevo formato
  static Future<bool> migrarDatosAntiguos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? datosAntiguos = prefs.getString('peso_registros_antiguos');
      
      if (datosAntiguos != null) {
        // Aquí puedes agregar lógica para migrar datos del formato anterior
        // Por ahora, simplemente eliminamos la clave antigua
        await prefs.remove('peso_registros_antiguos');
      }
      
      return true;
    } catch (e) {
      print('Error al migrar datos antiguos: $e');
      return false;
    }
  }
}