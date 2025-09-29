import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

// Menú principal con barra superior, tarjeta de mascota y navegación inferior.
import 'crear_mascota_nueva_pantalla.dart';
import '../modulo_calendario/calendario.dart';
import 'placeholder_funcion.dart';
import 'buscar.dart';
import '../modulo_peso/peso.dart';
import '../modulo_vacunas/vacunas_pantalla.dart'; // NUEVO import
import '../modulo_eventos/eventos_pantalla.dart'; // NUEVO import
import '../modulo_calendario/calendario_modulo_pantalla.dart'; // NUEVO import calendario
import '../modulo_album/album_modulo_pantalla.dart'; // NUEVO import álbum
import '../modulo_dueno/dueno_modulo_pantalla.dart'; // NUEVO import dueño
import '../modulo_configuracion/configuracion_modulo_pantalla.dart'; // NUEVO import configuración
import 'datos/mascota_model.dart';
import 'editar_mascota_pantalla.dart';

class MenuPrincipal extends StatefulWidget {
  final int initialTab; // 0 mascotas, 1 calendario, 2 configuración
  const MenuPrincipal({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  final Color green = const Color(0xFF4CAF50);
  late int _tabIndex; // 0: Mascota, 1: Calendario, 2: Ajustes
  bool _visible = true; // segment Visible/Oculto
  final MascotasRepo _repo = MascotasRepo();

  void _onRepoChange() => setState(() {});

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTab;
    _repo.addListener(_onRepoChange);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChange);
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
                          _repo.actualizarImagen(mascotaId, image.path);
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
                          _repo.actualizarImagen(mascotaId, image.path);
                        }
                      },
                    ),
                    _OpcionImagen(
                      icon: Icons.delete,
                      label: 'Eliminar',
                      onTap: () {
                        Navigator.pop(context);
                        _repo.actualizarImagen(mascotaId, null);
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

  Future<void> _mostrarMenuMascota(Mascota mascota) async {
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
                  'Opciones para ${mascota.nombre}',
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
                        builder: (_) => EditarMascotaPantalla(mascotaId: mascota.id),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    mascota.oculto ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF4CAF50),
                  ),
                  title: Text(mascota.oculto ? 'Mostrar mascota' : 'Ocultar mascota'),
                  onTap: () {
                    Navigator.pop(context);
                    _repo.toggleOculto(mascota.id);
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

  Future<void> _confirmarEliminarMascota(Mascota mascota) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar mascota'),
          content: Text('¿Estás seguro de que quieres eliminar a ${mascota.nombre}? Esta acción no se puede deshacer.'),
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
      _repo.eliminar(mascota.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${mascota.nombre} ha sido eliminado')),
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

  // Lista dinámica de tarjetas de mascotas (visibles u ocultas).
  Widget _buildPetCardsList() {
    final visibles = _repo.visibles;
    final ocultas = _repo.ocultas;
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

  Widget _petCard(Mascota m) {
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
            onTap: () => _cambiarFotoMascota(m.id),
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
          Text(m.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(m.obtenerEdadFormateada(), style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _FeatureButton(label: 'Peso', onTap: () => _openFeature('Peso')),
                    _FeatureButton(label: 'Vacunas', onTap: () => _openFeature('Vacunas')),
                    _FeatureButton(label: 'Albúm', onTap: () => _openFeature('Albúm')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _FeatureButton(label: 'Calendario', onTap: () => _openFeature('Calendario')),
                    _FeatureButton(label: 'Eventos', onTap: () => _openFeature('Eventos')),
                    _FeatureButton(label: 'Dueño', onTap: () => _openFeature('Dueño')),
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

  void _openFeature(String title) {
    if (title == 'Peso') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PesoPantalla()),
      );
    } else if (title == 'Vacunas') { // NUEVO caso
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VacunasPantalla()),
      );
    } else if (title == 'Eventos') { // NUEVO caso
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EventosPantalla()),
      );
    } else if (title == 'Calendario') { // NUEVO caso calendario
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CalendarioModuloPantalla()),
      );
    } else if (title == 'Albúm') { // NUEVO caso álbum
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AlbumModuloPantalla()),
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
  DecorationImage? _getImageDecoration(Mascota m) {
    if (m.imagenPath != null) {
      // Para móvil usa FileImage, para web usa NetworkImage con el path
      if (kIsWeb) {
        return DecorationImage(
          image: NetworkImage(m.imagenPath!),
          fit: BoxFit.cover,
        );
      } else {
        return DecorationImage(
          image: FileImage(File(m.imagenPath!)),
          fit: BoxFit.cover,
        );
      }
    } else {
      // Imagen por defecto
      return const DecorationImage(
        image: AssetImage('assets/images/perro_logo.png'),
        fit: BoxFit.cover,
      );
    }
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
