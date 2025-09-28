import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'servicios/album_service.dart';

class SubirFotoPantalla extends StatefulWidget {
  final String mes;
  final String ano;

  const SubirFotoPantalla({
    Key? key,
    required this.mes,
    required this.ano,
  }) : super(key: key);

  @override
  State<SubirFotoPantalla> createState() => _SubirFotoPantallaState();
}

class _SubirFotoPantallaState extends State<SubirFotoPantalla> {
  final Color _greenColor = const Color(0xFF4CAF50);
  final AlbumService _albumService = AlbumService();
  final TextEditingController _descripcionController = TextEditingController();
  
  String? _rutaImagenSeleccionada;
  bool _subiendo = false;
  int _fotosExistentes = 0;

  @override
  void initState() {
    super.initState();
    _cargarFotosExistentes();
  }

  Future<void> _cargarFotosExistentes() async {
    try {
      final fotoMes = await _albumService.obtenerFotoPorMes(widget.mes, widget.ano);
      setState(() {
        _fotosExistentes = fotoMes?.cantidadImagenes ?? 0;
      });
    } catch (e) {
      print('Error al cargar fotos existentes: $e');
      // En caso de error, limpiar datos corruptos
      await _albumService.limpiarDatos();
      setState(() {
        _fotosExistentes = 0;
      });
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    // Mostrar opciones de selección
    final opcion = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Seleccionar imagen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
                title: const Text('Galería'),
                onTap: () => Navigator.pop(context, 'galeria'),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
                title: Text(kIsWeb ? 'Seleccionar imagen' : 'Cámara'),
                subtitle: kIsWeb ? const Text('Cámara no disponible en web') : null,
                onTap: () => Navigator.pop(context, 'camara'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (opcion != null) {
      setState(() {
        _subiendo = true;
      });

      try {
        String? rutaImagen;
        
        if (opcion == 'galeria') {
          rutaImagen = await _albumService.seleccionarImagen();
        } else if (opcion == 'camara') {
          rutaImagen = await _albumService.tomarFoto();
        }
        
        if (rutaImagen != null) {
          setState(() {
            _rutaImagenSeleccionada = rutaImagen;
            _subiendo = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen seleccionada correctamente'),
              backgroundColor: Color(0xFF4CAF50),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          setState(() {
            _subiendo = false;
          });
        }
      } catch (e) {
        setState(() {
          _subiendo = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _guardarFoto() async {
    if (_rutaImagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una imagen primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_fotosExistentes >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya tienes el máximo de 4 fotos para este mes'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _subiendo = true;
    });

    try {
      // Usar el nuevo método que agrega la foto al mes
      await _albumService.agregarFotoAlMes(
        widget.mes,
        widget.ano,
        _rutaImagenSeleccionada!,
        _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foto guardada correctamente (${_fotosExistentes + 1}/4)'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
        ),
      );

      // Regresar con resultado exitoso
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _subiendo = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greenColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _greenColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Subir Foto',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Área de imagen
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _subiendo
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                    )
                  : _rutaImagenSeleccionada != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: _buildImageWidget(_rutaImagenSeleccionada!),
                        )
                      : _buildPlaceholderImage(),
            ),

            const SizedBox(height: 20),

            // Botón para subir imagen
            ElevatedButton.icon(
              onPressed: _subiendo ? null : _seleccionarImagen,
              icon: const Icon(Icons.camera_alt),
              label: Text(_rutaImagenSeleccionada == null ? 'Subir una imagen' : 'Cambiar imagen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _greenColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Fecha y contador de fotos
            Column(
              children: [
                Text(
                  'Foto va para ${widget.mes} ${widget.ano}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  'Tienes $_fotosExistentes de 4 fotos',
                  style: TextStyle(
                    color: _fotosExistentes >= 4 ? Colors.orange.shade200 : Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_fotosExistentes >= 4)
                  Text(
                    '¡Máximo de fotos alcanzado!',
                    style: TextStyle(
                      color: Colors.orange.shade200,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Campo de descripción
            const Text(
              'Describe este momento',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(15),
                  hintText: 'Agrega una descripción para esta foto...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Botón guardar
            ElevatedButton(
              onPressed: (_subiendo || _fotosExistentes >= 4) ? null : _guardarFoto,
              style: ElevatedButton.styleFrom(
                backgroundColor: _fotosExistentes >= 4 ? Colors.grey : const Color(0xFFFFB74D), // Color naranja o gris
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: _subiendo
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(_fotosExistentes >= 4 ? 'Máximo alcanzado' : 'Guardar'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildImageWidget(String rutaImagen) {
    if (kIsWeb) {
      // En web, usamos Network image ya que image_picker devuelve blob URLs
      return Image.network(
        rutaImagen,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
          );
        },
      );
    } else {
      // En móvil, usamos File
      return Image.file(
        File(rutaImagen),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
          Text(
            'Subir una imagen',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.pets, false),
          _buildNavItem(Icons.calendar_month, false),
          _buildNavItem(Icons.settings, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            )
          : null,
      child: Icon(
        icon,
        color: Colors.black,
        size: 28,
      ),
    );
  }
}