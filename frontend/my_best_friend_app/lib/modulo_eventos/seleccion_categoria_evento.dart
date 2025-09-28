import 'package:flutter/material.dart';

class SeleccionCategoriaEvento extends StatefulWidget {
  const SeleccionCategoriaEvento({Key? key}) : super(key: key);

  @override
  State<SeleccionCategoriaEvento> createState() => _SeleccionCategoriaEventoState();
}

class _SeleccionCategoriaEventoState extends State<SeleccionCategoriaEvento> {
  final Color _greenColor = const Color(0xFF4CAF50);
  String? _categoriaSeleccionada;

  final List<Map<String, dynamic>> _categorias = [
    {'nombre': 'Paseo', 'icono': Icons.directions_walk, 'color': Colors.blue},
    {'nombre': 'Juego', 'icono': Icons.sports_basketball, 'color': Colors.orange},
    {'nombre': 'Comida', 'icono': Icons.restaurant, 'color': Colors.red},
    {'nombre': 'Baño', 'icono': Icons.bathtub, 'color': Colors.lightBlue},
    {'nombre': 'Veterinario', 'icono': Icons.local_hospital, 'color': Colors.green},
    {'nombre': 'Entrenamiento', 'icono': Icons.school, 'color': Colors.purple},
    {'nombre': 'Socialización', 'icono': Icons.group, 'color': Colors.pink},
    {'nombre': 'Descanso', 'icono': Icons.bed, 'color': Colors.brown},
  ];

  void _seleccionarCategoria() {
    if (_categoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una categoría'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context, _categoriaSeleccionada);
  }

  Widget _buildCategoriaButton(Map<String, dynamic> categoria) {
    final bool isSelected = _categoriaSeleccionada == categoria['nombre'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _categoriaSeleccionada = categoria['nombre'];
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? Border.all(color: _greenColor, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              categoria['icono'],
              color: categoria['color'],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              categoria['nombre'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greenColor,
      appBar: AppBar(
        backgroundColor: _greenColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                '¿Qué te gustaría\nregistrar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 8,
              spacing: 8,
              children: _categorias.map((categoria) => _buildCategoriaButton(categoria)).toList(),
            ),
            const SizedBox(height: 110), // Espacio fijo controlado
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _seleccionarCategoria,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _greenColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
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
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            _BottomItem(
              icon: Icons.calendar_month,
              selected: false,
              onTap: () {},
            ),
            _BottomItem(
              icon: Icons.settings,
              selected: false,
              onTap: () {},
            ),
          ],
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