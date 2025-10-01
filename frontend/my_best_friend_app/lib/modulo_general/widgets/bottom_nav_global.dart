import 'package:flutter/material.dart';

import '../menu_principal.dart';

/// Barra de navegación inferior global reutilizable.
/// Indices:
/// 0 = Mascotas
/// 1 = Calendario (vista combinada eventos + recordatorios)
/// 2 = Configuración
class BottomNavGlobal extends StatelessWidget {
  final int selectedIndex; // -1 = ninguna pestaña resaltada
  const BottomNavGlobal({super.key, required this.selectedIndex});

  void _navigate(BuildContext context, int index) {
  if (index == selectedIndex) return; // Ya estamos en la pestaña (si hay selección)
    // Reinicia la pila y abre el MenuPrincipal en la pestaña solicitada
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MenuPrincipal(initialTab: index),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            selected: selectedIndex == 0,
            onTap: () => _navigate(context, 0),
          ),
          _BottomItem(
            icon: Icons.calendar_month,
            selected: selectedIndex == 1,
            onTap: () => _navigate(context, 1),
          ),
          _BottomItem(
            icon: Icons.settings,
            selected: selectedIndex == 2,
            onTap: () => _navigate(context, 2),
          ),
        ],
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
        child: Icon(icon, size: 28, color: Colors.black.withOpacity(selected ? 1 : 1)),
      ),
    );
  }
}
