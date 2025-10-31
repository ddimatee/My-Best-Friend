import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../modelos/foto_album.dart';

class AlbumService {
  static const String _keyFotos = 'album_fotos';

  Future<List<FotoAlbum>> obtenerFotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? fotosJson = prefs.getString(_keyFotos);
      
      if (fotosJson != null && fotosJson.isNotEmpty) {
        final dynamic decodedJson = json.decode(fotosJson);
        
        if (decodedJson is List) {
          List<FotoAlbum> fotosParseadas = [];
          
          for (var item in decodedJson) {
            if (item is Map<String, dynamic>) {
              try {
                fotosParseadas.add(FotoAlbum.fromJson(item));
              } catch (e) {
                print('Error al parsear foto individual: $e');
                // Continuar con las otras fotos
              }
            }
          }
          
          // Si no hay fotos parseadas o faltan meses, inicializar
          if (fotosParseadas.length < 12) {
            return _completarMesesFaltantes(fotosParseadas);
          }
          
          return fotosParseadas;
        }
      }
      
      return _inicializarFotosVacias();
    } catch (e) {
      print('Error al obtener fotos: $e');
      return _inicializarFotosVacias();
    }
  }

  List<FotoAlbum> _completarMesesFaltantes(List<FotoAlbum> fotosExistentes) {
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    List<FotoAlbum> todasLasFotos = List.from(fotosExistentes);
    
    for (String mes in meses) {
      bool existeMes = todasLasFotos.any((foto) => foto.mes == mes && foto.ano == '2025');
      if (!existeMes) {
        todasLasFotos.add(FotoAlbum(
          id: '${mes}_2025',
          mes: mes,
          ano: '2025',
          fechaSubida: DateTime.now(),
        ));
      }
    }
    
    return todasLasFotos;
  }

  Future<void> guardarFoto(FotoAlbum foto) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<FotoAlbum> fotos = await obtenerFotos();
      
      // Buscar si ya existe una entrada para ese mes
      int index = fotos.indexWhere((f) => f.mes == foto.mes && f.ano == foto.ano);
      
      if (index != -1) {
        // Actualizar foto existente
        fotos[index] = foto;
      } else {
        // Agregar nueva entrada de mes
        fotos.add(foto);
      }
      
      final String fotosJson = json.encode(fotos.map((f) => f.toJson()).toList());
      await prefs.setString(_keyFotos, fotosJson);
    } catch (e) {
      print('Error al guardar foto: $e');
      throw Exception('No se pudo guardar la foto');
    }
  }

  Future<FotoAlbum> agregarFotoAlMes(String mes, String ano, String rutaImagen, String? descripcion) async {
    if (rutaImagen.isEmpty || mes.isEmpty || ano.isEmpty) {
      throw Exception('Datos inválidos para agregar foto');
    }
    
    try {
      FotoAlbum? fotoMes = await obtenerFotoPorMes(mes, ano);
      
      if (fotoMes == null) {
        // Crear nueva entrada para el mes
        fotoMes = FotoAlbum(
          id: '${mes}_${ano}',
          mes: mes,
          ano: ano,
          rutasImagenes: [rutaImagen],
          descripcion: descripcion,
          fechaSubida: DateTime.now(),
        );
      } else {
        // Verificar que no se exceda el límite
        if (fotoMes.cantidadImagenes >= 4) {
          throw Exception('Ya tienes el máximo de 4 fotos para este mes');
        }
        
        // Agregar imagen al mes existente
        fotoMes = fotoMes.agregarImagen(rutaImagen);
        if (descripcion != null && descripcion.isNotEmpty) {
          fotoMes = fotoMes.copyWith(descripcion: descripcion);
        }
      }
      
      await guardarFoto(fotoMes);
      return fotoMes;
    } catch (e) {
      print('Error al agregar foto al mes: $e');
      rethrow;
    }
  }

  Future<FotoAlbum?> obtenerFotoPorMes(String mes, String ano) async {
    final fotos = await obtenerFotos();
    try {
      return fotos.firstWhere((foto) => foto.mes == mes && foto.ano == ano);
    } catch (e) {
      return null;
    }
  }

  Future<void> eliminarFoto(String mes, String ano) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<FotoAlbum> fotos = await obtenerFotos();
      
      fotos.removeWhere((foto) => foto.mes == mes && foto.ano == ano);
      
      final String fotosJson = json.encode(fotos.map((f) => f.toJson()).toList());
      await prefs.setString(_keyFotos, fotosJson);
    } catch (e) {
      print('Error al eliminar foto: $e');
      throw Exception('No se pudo eliminar la foto');
    }
  }

  Future<void> eliminarFotoIndividual(String mes, String ano, int indice) async {
    try {
      FotoAlbum? fotoMes = await obtenerFotoPorMes(mes, ano);
      if (fotoMes != null && indice < fotoMes.rutasImagenes.length) {
        List<String> nuevasRutas = List<String>.from(fotoMes.rutasImagenes);
        nuevasRutas.removeAt(indice);
        
        if (nuevasRutas.isEmpty) {
          // Si no quedan imágenes, eliminar toda la entrada del mes
          await eliminarFoto(mes, ano);
        } else {
          // Actualizar con las imágenes restantes
          final fotoActualizada = fotoMes.copyWith(rutasImagenes: nuevasRutas);
          await guardarFoto(fotoActualizada);
        }
      }
    } catch (e) {
      print('Error al eliminar foto individual: $e');
      throw Exception('No se pudo eliminar la foto');
    }
  }

  List<FotoAlbum> _inicializarFotosVacias() {
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return meses.map((mes) => FotoAlbum(
      id: '${mes}_2025',
      mes: mes,
      ano: '2025',
      fechaSubida: DateTime.now(),
    )).toList();
  }

  // Método para limpiar datos corruptos (útil para desarrollo)
  Future<void> limpiarDatos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyFotos);
    } catch (e) {
      print('Error al limpiar datos: $e');
    }
  }

  // Método para seleccionar imagen desde galería (compatible con web y móvil)
  Future<String?> seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      
      if (image != null) {
        // En web, usamos la ruta como está. En móvil, también.
        return image.path;
      }
      
      return null;
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      throw Exception('No se pudo seleccionar la imagen');
    }
  }

  // Método para tomar foto con la cámara (solo móvil, en web usa galería)
  Future<String?> tomarFoto() async {
    final ImagePicker picker = ImagePicker();
    
    try {
      // En web, la cámara no está tan bien soportada, así que usamos galería
      if (kIsWeb) {
        return await seleccionarImagen();
      }
      
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      
      if (image != null) {
        return image.path;
      }
      
      return null;
    } catch (e) {
      print('Error al tomar foto: $e');
      throw Exception('No se pudo tomar la foto');
    }
  }
}