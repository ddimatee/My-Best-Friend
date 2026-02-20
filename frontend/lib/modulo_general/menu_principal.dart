import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

// Menú principal con barra superior, tarjeta de mascota y navegación inferior.
import 'crear_mascota_nueva_pantalla.dart';
import '../modulo_calendario/calendario.dart';
import 'placeholder_funcion.dart';
import 'buscar.dart';
import '../modulo_peso/lista_pesos_pantalla.dart'; // NUEVO import
import '../modulo_vacunas/vacunas_pantalla.dart'; // NUEVO import
import '../modulo_eventos/eventos_pantalla.dart'; // NUEVO import
import '../modulo_calendario/calendario_modulo_pantalla.dart'; // NUEVO import calendario
import '../modulo_album/album_modulo_pantalla.dart'; // NUEVO import álbum
import '../modulo_dueno/dueno_modulo_pantalla.dart'; // NUEVO import dueño
import '../modulo_configuracion/configuracion_modulo_pantalla.dart'; // NUEVO import configuración
// Eliminado uso de modelo legacy; trabajamos directo con Map de provider
import 'package:provider/provider.dart';
import '../../providers/mascotas_provider.dart';
import 'editar_mascota_pantalla.dart';

class MenuPrincipal extends StatefulWidget {
  final int initialTab; // 0 mascotas, 1 calendario, 2 configuración
  const MenuPrincipal({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  final Color green = const Color(0xFF4CAF50);
  late int _tabIndex; // 0: Mascotas, 1: Calendario, 2: Configuración
  bool _visible = true; // segment Visible/Oculto
  // Eliminamos dependencia directa de MascotasRepo para usar provider


  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTab;
    // Cargar mascotas desde backend si hay sesión
    // Usamos addPostFrameCallback para esperar que el contexto esté listo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final mascotasProv = context.read<MascotasProvider>();
        mascotasProv.cargarMascotas();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openSearch() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const BuscarPantalla()));
  }

  void _openAddPet() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CrearMascotaNuevaPantalla()));
  }

  Future<void> _cambiarFotoMascota(String mascotaId) async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cambiar foto de perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _OpcionImagen(
                      icon: Icons.photo_library,
                      label: 'Galería',
                      onTap: () async {
                        Navigator.pop(context);
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 512,
                          maxHeight: 512,
                          imageQuality: 85,
                        );
                        if (image != null) {
                          final prov = context.read<MascotasProvider>();
                          final ok = await prov.subirFoto(mascotaId, image.path);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(ok ? 'Foto actualizada' : (prov.error ?? 'Error actualizando foto'))),
                          );
                        }
                      },
                    ),
                    _OpcionImagen(
                      icon: Icons.camera_alt,
                      label: 'Cámara',
                      onTap: () async {
                        Navigator.pop(context);
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.camera,
                          maxWidth: 512,
                          maxHeight: 512,
                          imageQuality: 85,
                        );
                        if (image != null) {
                          final prov = context.read<MascotasProvider>();
                          final ok = await prov.subirFoto(mascotaId, image.path);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(ok ? 'Foto actualizada' : (prov.error ?? 'Error actualizando foto'))),
                          );
                        }
                      },
                    ),
                    _OpcionImagen(
                      icon: Icons.delete,
                      label: 'Eliminar',
                      onTap: () async {
                        Navigator.pop(context);
                        final prov = context.read<MascotasProvider>();
                        // Limpiar foto -> actualizarMascota con fotoPerfil vacío
                        final ok = await prov.actualizarMascota(mascotaId, {'fotoPerfil': ''});
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(ok ? 'Foto eliminada' : (prov.error ?? 'Error eliminando foto'))),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _mostrarMenuMascota(Map<String,dynamic> mascota) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Opciones para ${mascota['nombre'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
                  title: const Text('Editar información'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditarMascotaPantalla(mascotaId: (mascota['_id'] ?? mascota['id']).toString()),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    (mascota['oculto'] == true) ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF4CAF50),
                  ),
                  title: Text(mascota['oculto'] == true ? 'Mostrar mascota' : 'Ocultar mascota'),
                  onTap: () {
                    Navigator.pop(context);
                    final prov = context.read<MascotasProvider>();
                    final id = (mascota['_id'] ?? mascota['id']).toString();
                    prov.toggleOculto(id);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Eliminar mascota', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmarEliminarMascota(mascota);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmarEliminarMascota(Map<String,dynamic> mascota) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar mascota'),
          content: Text('¿Estás seguro de que quieres eliminar a ${mascota['nombre']}? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (resultado == true) {
      final prov = context.read<MascotasProvider>();
  final id = (mascota['_id'] ?? mascota['id']).toString();
  final ok = await prov.eliminarMascota(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(ok ? '${mascota['nombre']} ha sido eliminado' : (prov.error ?? 'Error eliminando mascota'))),
      );
    }
  }

  Widget _buildTopBar() {
    // Solo mostrar la barra superior completa en la pestaña de mascotas (índice 0)
    if (_tabIndex != 0) {
      return const SizedBox(height: 8); // Espacio mínimo para las otras pestañas
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _openSearch,
            icon: const Icon(Icons.search, color: Colors.black, size: 28),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                  ],
                ),
                //OPCIONES DE VISIBLE/OCULTO
                width: 220,
                height: 40,
                child: Row(
                  children: [
                    _SegmentItem(
                      label: 'Visible',
                      selected: _visible,
                      onTap: () => setState(() => _visible = true),
                    ),
                    _SegmentItem(
                      label: 'Oculto',
                      selected: !_visible,
                      onTap: () => setState(() => _visible = false),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _openAddPet,
            icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 28),
          ),
        ],
      ),
    );
  }

// Franja decorativa con patrón de iconos.
  Widget _buildPatternStrip() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Icon(Icons.pets, color: Colors.black54),
            Icon(Icons.circle, color: Colors.orange, size: 12),
            Icon(Icons.pets, color: Colors.black54),
            Icon(Icons.sports_baseball, color: Colors.deepOrangeAccent),
            Icon(Icons.pets, color: Colors.black54),
            Icon(Icons.circle, color: Colors.orange, size: 12),
            Icon(Icons.pets, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  // Lista dinámica de tarjetas de mascotas (visibles u ocultas) usando Map directamente.
  Widget _buildPetCardsList() {
    final mascotasProvider = context.watch<MascotasProvider>();
    final todas = mascotasProvider.mascotas;
    final visibles = todas.where((m) => !(m['oculto'] == true)).toList();
    final ocultas = todas.where((m) => m['oculto'] == true).toList();
    final lista = _visible ? visibles : ocultas;
    if (visibles.isEmpty && ocultas.isEmpty) {
      return _emptyState('Aún no has agregado una mascota');
    }
    if (lista.isEmpty) {
      return _emptyState(_visible ? 'No hay mascotas visibles' : 'No hay mascotas ocultas');
    }
    return Column(
      children: lista.map((m) => _petCard(m)).toList(),
    );
  }

  Widget _emptyState(String mensaje) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(mensaje, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _openAddPet,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text('Agregar Mascota'),
          ),
        ],
      ),
    );
  }

  Widget _petCard(Map<String,dynamic> m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildPatternStrip(),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _cambiarFotoMascota((m['_id'] ?? m['id']).toString()),
            child: Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                    image: _getImageDecoration(m),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(m['nombre'] ?? 'Sin nombre', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(_edadFormateada(m), style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _FeatureButton(label: 'Peso', onTap: () => _openFeature('Peso', m)),
                    _FeatureButton(label: 'Vacunas', onTap: () => _openFeature('Vacunas', m)),
                    _FeatureButton(label: 'Albúm', onTap: () => _openFeature('Albúm', m)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _FeatureButton(label: 'Recordatorios', onTap: () => _openFeature('Recordatorios', m)),
                    _FeatureButton(label: 'Eventos', onTap: () => _openFeature('Eventos', m)),
                    _FeatureButton(label: 'Dueño', onTap: () => _openFeature('Dueño', m)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _mostrarMenuMascota(m),
            icon: const Icon(Icons.more_vert, color: Colors.black87, size: 18),
            label: const Text('Opciones', style: TextStyle(color: Colors.black87, fontSize: 13)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _openFeature(String title, Map<String, dynamic> mascota) {
    final mascotaId = (mascota['_id'] ?? mascota['id'])?.toString();
    if (title == 'Peso') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ListaPesosPantalla(mascotaId: mascotaId)),
      );
    } else if (title == 'Vacunas') { // NUEVO caso
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VacunasPantalla(mascotaId: mascotaId, bloquearMascota: true)),
      );
    } else if (title == 'Eventos') { // NUEVO caso
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventosPantalla(mascotaId: mascotaId, bloquearMascota: true)),
      );
  } else if (title == 'Recordatorios') { // Caso para módulo de recordatorios/calendario
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CalendarioModuloPantalla(mascota: mascota)),
      );
    } else if (title == 'Albúm') { // NUEVO caso álbum
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AlbumModuloPantalla(mascotaId: mascotaId, bloquearMascota: true)),
      );
    } else if (title == 'Dueño') { // NUEVO caso dueño
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DuenoModuloPantalla()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlaceholderFuncionPantalla(title: title)),
      );
    }
  }

  String _edadFormateada(Map<String,dynamic> m) {
    final fechaStr = m['fechaNacimiento'] ?? m['fecha_nac'] ?? m['cumpleanos'] ?? m['createdAt'];
    DateTime? base;
    if (fechaStr is String) base = DateTime.tryParse(fechaStr);
    if (fechaStr is DateTime) base = fechaStr;
    if (base == null) return '';
    final diff = DateTime.now().difference(base);
    final dias = diff.inDays;
    final meses = (dias / 30.44).floor();
    if (meses == 0) return '$dias días';
    if (meses < 12) return '$dias días ($meses meses)';
  final anios = (meses / 12).floor();
  final rem = meses % 12;
  if (rem == 0) return '$anios ${anios==1?'año':'años'}';
  return '$anios ${anios==1?'año':'años'} y $rem ${rem==1?'mes':'meses'}';
  }

  Widget _buildContentForTab() {
    switch (_tabIndex) {
      case 0:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildPetCardsList(),
              const SizedBox(height: 80), // Espacio para evitar que la barra inferior tape el contenido
            ],
          ),
        );
      case 1:
        return const CalendarioPantalla();
      case 2:
        return const ConfiguracionModuloPantalla();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomNav() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Container(
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BottomItem(
                icon: Icons.pets,
                selected: _tabIndex == 0,
                onTap: () => setState(() => _tabIndex = 0),
              ),
              _BottomItem(
                icon: Icons.calendar_month,
                selected: _tabIndex == 1,
                onTap: () => setState(() => _tabIndex = 1),
              ),
              _BottomItem(
                icon: Icons.settings,
                selected: _tabIndex == 2,
                onTap: () => setState(() => _tabIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: green,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildContentForTab(),
                  ),
                ),
              ],
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // Método para obtener la decoración de imagen que funciona tanto en web como móvil
  DecorationImage? _getImageDecoration(Map<String,dynamic> m) {
    final path = m['fotoPerfil'];
    if (path is String && path.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(path),
        fit: BoxFit.cover,
      );
    }
    return const DecorationImage(
      image: AssetImage('assets/images/perro_logo.png'),
      fit: BoxFit.cover,
    );
  }
}

class _OpcionImagen extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OpcionImagen({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FeatureButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegmentItem({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: selected
                ? const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _BottomItem({required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: selected
              ? const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]
              : null,
        ),
        child: Icon(icon, size: 28, color: Colors.black),
      ),
    );
  }
}
