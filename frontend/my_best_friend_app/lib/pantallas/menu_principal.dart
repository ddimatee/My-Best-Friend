import 'package:flutter/material.dart';

// Menú principal con barra superior, tarjeta de mascota y navegación inferior.
import '../formularios/formulario_mascota.dart';
import 'calendario.dart';
import 'ajustes.dart';
import 'placeholder_funcion.dart';
import 'buscar.dart';
import 'peso.dart';
import '../pantallas_vacunas/vacunas_pantalla.dart'; // NUEVO import
import '../pantallas_eventos/eventos_pantalla.dart'; // NUEVO import
import '../pantallas_calendario/calendario_modulo_pantalla.dart'; // NUEVO import calendario
import '../pantallas_album/album_modulo_pantalla.dart'; // NUEVO import álbum
import '../pantallas_dueno/dueno_modulo_pantalla.dart'; // NUEVO import dueño

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({Key? key}) : super(key: key);
  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  final Color green = const Color(0xFF4CAF50);
  int _tabIndex = 0; // 0: Mascota, 1: Calendario, 2: Ajustes
  bool _visible = true; // segment Visible/Oculto

  void _openSearch() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const BuscarPantalla()));
  }

  void _openAddPet() {
    final st = PetFormState();
    Navigator.push(context, MaterialPageRoute(builder: (_) => MascotaPasoSituacionPantalla(estado: st)));
  }

  Widget _buildTopBar() {
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

// Tarjeta de mascota con foto, nombre, edad y botones de función.
  Widget _buildPetCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildPatternStrip(),
          const SizedBox(height: 12),
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: const AssetImage('assets/images/perro_logo.png'),
          ),
          const SizedBox(height: 8),
          const Text('Mascota', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('0 días (0 meses)', style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Column(
              children: [
                // Fila de botones de función
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
              _buildPetCard(),
            ],
          ),
        );
      case 1:
        return const CalendarioPantalla();
      case 2:
        return const AjustesPantalla();
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
