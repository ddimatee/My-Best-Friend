import 'package:flutter/material.dart';

import 'screens/add_pet_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/feature_placeholder.dart';
import 'screens/search_screen.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);
  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final Color green = const Color(0xFF4CAF50);
  int _tabIndex = 0; // 0: Mascota, 1: Calendario, 2: Ajustes
  bool _visible = true; // segment Visible/Oculto

  void _openSearch() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
  }

  void _openAddPet() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPetScreen()));
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search icon (left)
          IconButton(
            onPressed: _openSearch,
            icon: const Icon(Icons.search, color: Colors.black, size: 28),
          ),

          // Segmented control (center)
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

          // Add button (right)
          IconButton(
            onPressed: _openAddPet,
            icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternStrip() {
    // Decorative band mimicking paw/bone pattern using icons
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FeaturePlaceholderScreen(title: title)),
    );
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
        return const CalendarScreen();
      case 2:
        return const SettingsScreen();
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
