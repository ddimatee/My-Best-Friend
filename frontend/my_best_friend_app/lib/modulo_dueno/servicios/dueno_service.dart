import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/dueno_model.dart';

class DuenoService {
  static const String _keyDueno = 'dueno_data';

  Future<DuenoModel?> obtenerDueno() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? duenoJson = prefs.getString(_keyDueno);
      
      if (duenoJson != null && duenoJson.isNotEmpty) {
        final Map<String, dynamic> duenoMap = json.decode(duenoJson);
        return DuenoModel.fromJson(duenoMap);
      }
      
      // Si no hay datos, crear un dueño por defecto
      return _crearDuenoPorDefecto();
    } catch (e) {
      print('Error al obtener dueño: $e');
      return _crearDuenoPorDefecto();
    }
  }

  Future<void> guardarDueno(DuenoModel dueno) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String duenoJson = json.encode(dueno.toJson());
      await prefs.setString(_keyDueno, duenoJson);
    } catch (e) {
      print('Error al guardar dueño: $e');
      throw Exception('No se pudo guardar la información del dueño');
    }
  }

  Future<void> actualizarDueno(DuenoModel dueno) async {
    await guardarDueno(dueno);
  }

  Future<void> eliminarDueno() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyDueno);
    } catch (e) {
      print('Error al eliminar dueño: $e');
      throw Exception('No se pudo eliminar la información del dueño');
    }
  }

  DuenoModel _crearDuenoPorDefecto() {
    return DuenoModel(
      id: 'dueno_001',
      nombre: 'Brayan',
      apellido: 'Dimate',
      telefono: '+57 300 123 4567',
      email: 'brayan.dimate@email.com',
      direccion: 'Calle 123 #45-67, Bogotá, Colombia',
      fechaCreacion: DateTime.now(),
    );
  }

  Future<bool> existeDueno() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_keyDueno);
    } catch (e) {
      return false;
    }
  }
}