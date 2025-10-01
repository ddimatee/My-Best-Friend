import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../providers/album_provider.dart';

class SubirFotoPantalla extends StatefulWidget {
  final String mascotaId;
  const SubirFotoPantalla({Key? key, required this.mascotaId}) : super(key: key);

  @override
  State<SubirFotoPantalla> createState() => _SubirFotoPantallaState();
}

class _SubirFotoPantallaState extends State<SubirFotoPantalla> {
  final Color _greenColor = const Color(0xFF4CAF50);
  final TextEditingController _descripcionController = TextEditingController();
  String? _rutaImagenSeleccionada;
  bool _subiendo = false;
  int _fotosExistentes = 0;
  bool _cargandoInicial = true;
  DateTime _fechaSeleccionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AlbumProvider>().cargar(mascotaId: widget.mascotaId);
      _contarFotos();
      if (mounted) setState(() { _cargandoInicial = false; });
    });
  }

  void _contarFotos() {
    _fotosExistentes = context.read<AlbumProvider>().fotos(widget.mascotaId).length;
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final opcion = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Text('Seleccionar imagen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, 'galeria'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
              title: Text(kIsWeb ? 'Seleccionar imagen' : 'Cámara'),
              subtitle: kIsWeb ? const Text('Cámara limitada en web') : null,
              onTap: () => Navigator.pop(context, 'camara'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (opcion == null) return;
    setState(() { _subiendo = true; });
    try {
      final picker = ImagePicker();
      XFile? file;
      if (opcion == 'galeria') {
        file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1920);
      } else if (opcion == 'camara' && !kIsWeb) {
        file = await picker.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 1920);
      } else if (opcion == 'camara' && kIsWeb) {
        // fallback web
        file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1920);
      }
      if (file != null) {
        setState(() { _rutaImagenSeleccionada = file!.path; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imagen seleccionada'), backgroundColor: Color(0xFF4CAF50)));        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() { _subiendo = false; });
    }
  }

  Future<void> _seleccionarFecha() async {
    // Usar un dialog personalizado simple con mes/año y día
    final DateTime? fecha = await showDialog<DateTime>(
      context: context,
      builder: (context) => _SelectorFechaPersonalizado(
        fechaInicial: _fechaSeleccionada,
        fechaMinima: DateTime(2020),
        fechaMaxima: DateTime.now(),
        colorPrimario: _greenColor,
      ),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> _guardarFoto() async {
    if (_rutaImagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una imagen'), backgroundColor: Colors.orange));
      return;
    }
    if (_fotosExistentes >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Máximo 4 fotos alcanzado'), backgroundColor: Colors.orange));
      return;
    }
    setState(() { _subiendo = true; });
    try {
      final prov = context.read<AlbumProvider>();
      final ok = await prov.subir(
        mascotaId: widget.mascotaId,
        url: _rutaImagenSeleccionada!,
        descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
        fecha: _fechaSeleccionada,
      );
      if (!ok) throw prov.error ?? 'Error desconocido';
      _contarFotos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto guardada (${_fotosExistentes}/4)'), backgroundColor: const Color(0xFF4CAF50)));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() { _subiendo = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greenColor,
      appBar: AppBar(
        backgroundColor: _greenColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Subir Foto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _cargandoInicial
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0,2))],
                    ),
                    child: _subiendo
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
                        : _rutaImagenSeleccionada != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: _buildImageWidget(_rutaImagenSeleccionada!),
                              )
                            : _buildPlaceholderImage(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _subiendo ? null : _seleccionarImagen,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_rutaImagenSeleccionada == null ? 'Seleccionar imagen' : 'Cambiar imagen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _greenColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      const Text('Foto para mascota', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('Tienes $_fotosExistentes de 4 fotos', style: TextStyle(color: _fotosExistentes >= 4 ? Colors.orange.shade200 : Colors.white70)),
                      if (_fotosExistentes >= 4)
                        Text('Máximo alcanzado', style: TextStyle(color: Colors.orange.shade200, fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Fecha de la foto', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _seleccionarFecha,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0,2))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_fechaSeleccionada.day.toString().padLeft(2, '0')}/${_fechaSeleccionada.month.toString().padLeft(2, '0')}/${_fechaSeleccionada.year}',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Descripción', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0,2))],
                    ),
                    child: TextField(
                      controller: _descripcionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14),
                        hintText: 'Descripción opcional...',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_subiendo || _fotosExistentes >= 4) ? null : _guardarFoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _fotosExistentes >= 4 ? Colors.grey : const Color(0xFFFFB74D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _subiendo
                          ? const SizedBox(height:20, width:20, child: CircularProgressIndicator(strokeWidth:2, color: Colors.white))
                          : Text(_fotosExistentes >= 4 ? 'Máximo alcanzado' : 'Guardar', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImageWidget(String path) {
    if (kIsWeb) {
      return Image.network(path, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (_, __, ___) => _buildPlaceholderImage());
    }
    return Image.file(File(path), fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (_, __, ___) => _buildPlaceholderImage());
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 70, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text('Sin imagen', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

// Widget personalizado para selector de fecha con días correctos
class _SelectorFechaPersonalizado extends StatefulWidget {
  final DateTime fechaInicial;
  final DateTime fechaMinima;
  final DateTime fechaMaxima;
  final Color colorPrimario;

  const _SelectorFechaPersonalizado({
    required this.fechaInicial,
    required this.fechaMinima,
    required this.fechaMaxima,
    required this.colorPrimario,
  });

  @override
  State<_SelectorFechaPersonalizado> createState() => _SelectorFechaPersonalizadoState();
}

class _SelectorFechaPersonalizadoState extends State<_SelectorFechaPersonalizado> {
  late DateTime _fechaSeleccionada;
  late int _mesActual;
  late int _anioActual;

  static const List<String> _nombresMeses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  static const List<String> _diasSemana = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = widget.fechaInicial;
    _mesActual = _fechaSeleccionada.month;
    _anioActual = _fechaSeleccionada.year;
  }

  void _cambiarMes(int delta) {
    setState(() {
      _mesActual += delta;
      if (_mesActual > 12) {
        _mesActual = 1;
        _anioActual++;
      } else if (_mesActual < 1) {
        _mesActual = 12;
        _anioActual--;
      }
    });
  }

  List<DateTime?> _obtenerDiasDelMes() {
    final primerDia = DateTime(_anioActual, _mesActual, 1);
    final ultimoDia = DateTime(_anioActual, _mesActual + 1, 0);
    final diasEnMes = ultimoDia.day;
    
    // Obtener día de la semana del primer día (1 = lunes, 7 = domingo)
    int primerDiaSemana = primerDia.weekday;
    
    final List<DateTime?> dias = [];
    
    // Agregar espacios vacíos antes del primer día
    for (int i = 1; i < primerDiaSemana; i++) {
      dias.add(null);
    }
    
    // Agregar los días del mes
    for (int dia = 1; dia <= diasEnMes; dia++) {
      dias.add(DateTime(_anioActual, _mesActual, dia));
    }
    
    return dias;
  }

  @override
  Widget build(BuildContext context) {
    final dias = _obtenerDiasDelMes();
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _cambiarMes(-1),
                ),
                Text(
                  '${_nombresMeses[_mesActual - 1]} $_anioActual',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _cambiarMes(1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Días de la semana
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _diasSemana.map((dia) => 
                SizedBox(
                  width: 40,
                  child: Text(
                    dia,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ).toList(),
            ),
            const SizedBox(height: 8),
            // Calendario
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: dias.length,
              itemBuilder: (context, index) {
                final fecha = dias[index];
                if (fecha == null) {
                  return const SizedBox();
                }
                
                final esSeleccionado = fecha.day == _fechaSeleccionada.day &&
                    fecha.month == _fechaSeleccionada.month &&
                    fecha.year == _fechaSeleccionada.year;
                
                final esFuturo = fecha.isAfter(widget.fechaMaxima);
                
                return InkWell(
                  onTap: esFuturo ? null : () {
                    setState(() {
                      _fechaSeleccionada = fecha;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: esSeleccionado ? widget.colorPrimario : null,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${fecha.day}',
                      style: TextStyle(
                        color: esFuturo
                            ? Colors.grey.shade300
                            : esSeleccionado
                                ? Colors.white
                                : Colors.black,
                        fontWeight: esSeleccionado ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_fechaSeleccionada),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.colorPrimario,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('ACEPTAR'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}