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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? _greenColor : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? _greenColor.withOpacity(0.25) : Colors.black12,
            blurRadius: isSelected ? 10 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _categoriaSeleccionada = categoria['nombre']),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: (categoria['color'] as Color).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    categoria['icono'],
                    color: categoria['color'],
                    size: 26,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  categoria['nombre'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: Colors.black.withOpacity(0.85),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                AnimatedOpacity(
                  opacity: isSelected ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    height: 6,
                    width: 6,
                    decoration: BoxDecoration(
                      color: _greenColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '¿Qué te gustaría registrar?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .2,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _categoriaSeleccionada == null
                        ? 'Selecciona una categoría para continuar'
                        : 'Has seleccionado: $_categoriaSeleccionada',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: _categorias.length,
                  itemBuilder: (context, index) => _buildCategoriaButton(_categorias[index]),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _seleccionarCategoria,
                icon: const Icon(Icons.arrow_forward, size: 20),
                label: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _greenColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 4,
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