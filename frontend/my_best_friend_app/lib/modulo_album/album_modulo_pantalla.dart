import 'package:flutter/material.dart';
import '../modulo_general/widgets/bottom_nav_global.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'subir_foto_pantalla.dart';
import 'package:provider/provider.dart';
import '../../providers/album_provider.dart';
import '../../providers/mascotas_provider.dart';

class AlbumModuloPantalla extends StatefulWidget {
  const AlbumModuloPantalla({Key? key}) : super(key: key);

  @override
  State<AlbumModuloPantalla> createState() => _AlbumModuloPantallaState();
}

class _AlbumModuloPantallaState extends State<AlbumModuloPantalla> {
  final Color _greenColor = const Color(0xFF4CAF50);
  bool _cargando = true;
  String? _mascotaSeleccionada;
  List<Map<String, dynamic>> _fotos = [];
  int _anioActual = DateTime.now().year;
  bool _cargandoMascotas = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mascProv = context.read<MascotasProvider>();
      if (mascProv.mascotas.isEmpty) {
        setState(() => _cargandoMascotas = true);
        await mascProv.cargarMascotas();
        if (mounted) setState(() => _cargandoMascotas = false);
      }
      if (mascProv.mascotas.isNotEmpty) {
        _mascotaSeleccionada = (mascProv.mascotas.first['_id'] ?? mascProv.mascotas.first['id']).toString();
        await context.read<AlbumProvider>().cargar(mascotaId: _mascotaSeleccionada);
        _refrescar();
      }
      if (mounted) setState(() { _cargando = false; });
    });
  }

  void _refrescar() {
    if (_mascotaSeleccionada != null) {
      _fotos = List.from(context.read<AlbumProvider>().fotos(_mascotaSeleccionada!));
    }
  }

  List<Map<String, dynamic>> _fotosDelMes(int mes) {
    // Filtrar fotos del año/mes indicado (se asume campo fechaSubida o fecha)
    return _fotos.where((f) {
      final fechaRaw = f['fechaSubida'] ?? f['fecha'] ?? f['createdAt'];
      DateTime? fecha;
      if (fechaRaw is DateTime) {
        fecha = fechaRaw;
      } else if (fechaRaw is String) {
        fecha = DateTime.tryParse(fechaRaw);
      }
      if (fecha == null) {
        debugPrint('⚠️ Foto sin fecha válida: $f');
        return false;
      }
      
      final coincide = fecha.year == _anioActual && fecha.month == mes;
      if (coincide) {
        debugPrint('✅ Foto encontrada para mes $mes: fecha=${fecha.toString()}, año=${fecha.year}, mes=${fecha.month}');
      }
      
      return coincide;
    }).take(4).toList();
  }

  static const List<String> _meses = [
    'Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'
  ];

  Future<void> _abrirSubirFoto() async {
    if (_mascotaSeleccionada == null) return;
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SubirFotoPantalla(mascotaId: _mascotaSeleccionada!),
      ),
    );

    if (resultado == true) {
      await context.read<AlbumProvider>().cargar(mascotaId: _mascotaSeleccionada);
      if (mounted) setState(() { _refrescar(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greenColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _anioActual.toString(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFB74D), // Color naranja del año
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                _buildSelectorMascota(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: GridView.builder(
                      key: ValueKey(_mascotaSeleccionada),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final mes = index + 1;
                        final fotosMes = _fotosDelMes(mes);
                        return _buildMesCard(mes, fotosMes);
                      },
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNavGlobal(selectedIndex: 0),
    );
  }

  Widget _buildSelectorMascota() {
    final mascProv = context.watch<MascotasProvider>();
    final lista = mascProv.mascotas;
    if (_cargandoMascotas) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: LinearProgressIndicator(minHeight: 6, backgroundColor: Colors.white54),
      );
    }
    if (lista.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16,16,16,8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text('No hay mascotas. Crea una para comenzar a subir fotos.', style: TextStyle(color: Colors.black87)),
      );
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16,16,16,8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0,2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.photo_library, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _mascotaSeleccionada,
                isExpanded: true,
                icon: const Icon(Icons.expand_more),
                items: lista.map((m) {
                  final id = (m['_id'] ?? m['id']).toString();
                  final nombre = (m['nombre'] ?? 'Mascota').toString();
                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                  );
                }).toList(),
                onChanged: (val) async {
                  if (val == null) return;
                  setState(() { _mascotaSeleccionada = val; _cargando = true; });
                  await context.read<AlbumProvider>().cargar(mascotaId: _mascotaSeleccionada);
                  if (mounted) {
                    _refrescar();
                    setState(() { _cargando = false; });
                  }
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _greenColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _anioActual.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMesCard(int mes, List<Map<String, dynamic>> fotosMes) {
    // Para cada foto usamos campo 'url'
    final rutas = fotosMes.map((f) => f['url']?.toString() ?? '').where((s) => s.isNotEmpty).take(4).toList();
    return GestureDetector(
      onTap: _abrirSubirFoto,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final tiene = index < fotosMes.length && index < 4;
                    final foto = tiene ? fotosMes[index] : null;
                    return GestureDetector(
                      onTap: () {
                        if (tiene && foto != null) {
                          _editarFoto(foto);
                        } else {
                          _abrirSubirFoto();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: tiene
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: _buildImageWidget(((foto?['url']) ?? '').toString()),
                              )
                            : _buildMiniPlaceholder(),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFE0E0E0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${_meses[mes-1]} $_anioActual',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text('${rutas.length}/4 fotos', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editarFoto(Map<String, dynamic> foto) {
    final descripcionInicial = (foto['descripcion'] ?? '').toString();
    final TextEditingController descCtrl = TextEditingController(text: descripcionInicial);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Editar Foto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 1.6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImageWidget((foto['url'] ?? '').toString()),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final id = (foto['_id'] ?? foto['id'])?.toString();
                        if (id == null) return;
                        final ok = await context.read<AlbumProvider>().actualizar(id, {
                          'descripcion': descCtrl.text.trim(),
                        });
                        if (ok) {
                          if (mounted) {
                            _refrescar();
                            setState(() {});
                          }
                          if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Descripción actualizada')));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar'), backgroundColor: Colors.red));
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _greenColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final id = (foto['_id'] ?? foto['id'])?.toString();
                        if (id == null) return;
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (dCtx) => AlertDialog(
                            title: const Text('Eliminar foto'),
                            content: const Text('¿Seguro que deseas eliminar esta foto?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancelar')),
                              ElevatedButton(onPressed: () => Navigator.pop(dCtx, true), child: const Text('Eliminar')),
                            ],
                          ),
                        );
                        if (confirmar == true) {
                          final ok = await context.read<AlbumProvider>().eliminar(id);
                          if (ok) {
                            if (mounted) {
                              _refrescar();
                              setState(() {});
                            }
                            if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto eliminada')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al eliminar'), backgroundColor: Colors.red));
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      }
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
          return _buildPlaceholderContent();
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
          return _buildPlaceholderContent();
        },
      );
    }
  }

  Widget _buildPlaceholderContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image_outlined,
          size: 40,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          'Sin imagen',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniPlaceholder() {
    return Center(
      child: Icon(
        Icons.add_photo_alternate_outlined,
        size: 20,
        color: Colors.grey.shade400,
      ),
    );
  }

}

// _BottomItem eliminado (se usa BottomNavGlobal)