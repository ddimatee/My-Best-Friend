import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/vacuna.dart';

class VacunaService {
  static const String _keyVacunas = 'vacunas_guardadas';

  // Obtener todas las vacunas
  static Future<List<Vacuna>> obtenerVacunas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? vacunasJson = prefs.getString(_keyVacunas);
    
    if (vacunasJson == null || vacunasJson.isEmpty) {
      return [];
    }
    
    final List<dynamic> vacunasList = json.decode(vacunasJson);
    return vacunasList.map((json) => Vacuna.fromJson(json)).toList();
  }

  // Guardar una nueva vacuna
  static Future<bool> guardarVacuna(Vacuna vacuna) async {
    try {
      final List<Vacuna> vacunas = await obtenerVacunas();
      vacunas.add(vacuna);
      
      final prefs = await SharedPreferences.getInstance();
      final String vacunasJson = json.encode(vacunas.map((v) => v.toJson()).toList());
      
      return await prefs.setString(_keyVacunas, vacunasJson);
    } catch (e) {
      return false;
    }
  }

  // Eliminar una vacuna
  static Future<bool> eliminarVacuna(String id) async {
    try {
      final List<Vacuna> vacunas = await obtenerVacunas();
      vacunas.removeWhere((vacuna) => vacuna.id == id);
      
      final prefs = await SharedPreferences.getInstance();
      final String vacunasJson = json.encode(vacunas.map((v) => v.toJson()).toList());
      
      return await prefs.setString(_keyVacunas, vacunasJson);
    } catch (e) {
      return false;
    }
  }

  // Actualizar una vacuna existente
  static Future<bool> actualizarVacuna(Vacuna vacunaActualizada) async {
    try {
      final List<Vacuna> vacunas = await obtenerVacunas();
      final int index = vacunas.indexWhere((v) => v.id == vacunaActualizada.id);
      
      if (index != -1) {
        vacunas[index] = vacunaActualizada;
        
        final prefs = await SharedPreferences.getInstance();
        final String vacunasJson = json.encode(vacunas.map((v) => v.toJson()).toList());
        
        return await prefs.setString(_keyVacunas, vacunasJson);
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
}