import 'package:flutter/material.dart';
import 'opciones_programacion_calendario.dart';
import 'modelos/evento_calendario.dart';

class SeleccionCategoriaCalendario extends StatefulWidget {
  final String descripcion;
  final EventoCalendario? recordatorioParaEditar; // Recordatorio a editar (opcional)
  final Map<String, dynamic>? mascota; // Información de la mascota seleccionada
  
  const SeleccionCategoriaCalendario({
    Key? key, 
    required this.descripcion,
    this.recordatorioParaEditar,
    this.mascota,
  }) : super(key: key);

  @override
  State<SeleccionCategoriaCalendario> createState() => _SeleccionCategoriaCalendarioState();
}

class _SeleccionCategoriaCalendarioState extends State<SeleccionCategoriaCalendario> {
  final Color _greenColor = const Color(0xFF4CAF50); // Verde consistente con la app
  final Color _grayColor = const Color(0xFFE5E5E5);
  String? _categoriaSeleccionada;

  final List<Map<String, dynamic>> _categorias = [
    {'id': 'vacunas', 'titulo': 'Vacunas', 'icono': Icons.vaccines},
    {'id': 'medicamentos', 'titulo': 'Medicamentos', 'icono': Icons.medication},
    {'id': 'alimentacion', 'titulo': 'Alimentación', 'icono': Icons.restaurant},
    {'id': 'ejercicio', 'titulo': 'Ejercicio', 'icono': Icons.directions_run},
    {'id': 'citas_veterinario', 'titulo': 'Citas con el veterinario', 'icono': Icons.local_hospital},
    {'id': 'aseo', 'titulo': 'Aseo', 'icono': Icons.bathtub},
    {'id': 'juegos', 'titulo': 'Juegos y entretenimiento', 'icono': Icons.sports_soccer},
    {'id': 'otro', 'titulo': 'Otro', 'icono': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    // Si estamos editando, precargar la categoría existente
    if (widget.recordatorioParaEditar != null) {
      _categoriaSeleccionada = widget.recordatorioParaEditar!.categoria;
    }
  }

  void _seleccionarCategoria(String categoria) {
    setState(() {
      _categoriaSeleccionada = categoria;
    });
  }

  void _continuar() {
    if (_categoriaSeleccionada != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OpcionesProgramacionCalendario(
            descripcion: widget.descripcion,
            categoria: _categoriaSeleccionada!,
            recordatorioParaEditar: widget.recordatorioParaEditar,
            mascota: widget.mascota,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greenColor,
      appBar: AppBar(
        backgroundColor: _grayColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header gris
          Container(
            width: double.infinity,
            color: _grayColor,
            padding: const EdgeInsets.only(bottom: 20),
            child: const Center(
              child: Text(
                '¿De qué te gustaría\nque te recuerde?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          
          // Cuerpo verde con categorías
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  
                  ..._categorias.map((categoria) => Column(
                    children: [
                      _CategoriaItem(
                        categoria: categoria,
                        seleccionada: _categoriaSeleccionada == categoria['id'],
                        onTap: () => _seleccionarCategoria(categoria['id']),
                      ),
                      const SizedBox(height: 12),
                    ],
                  )),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Botón flotante de continuar
      floatingActionButton: _categoriaSeleccionada != null
          ? Container(
              margin: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton.extended(
                onPressed: _continuar,
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                label: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                elevation: 4,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      
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
              onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
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

class _CategoriaItem extends StatelessWidget {
  final Map<String, dynamic> categoria;
  final bool seleccionada;
  final VoidCallback onTap;

  const _CategoriaItem({
    required this.categoria,
    required this.seleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: seleccionada ? const Color(0xFFFFC107) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: seleccionada 
              ? Border.all(color: const Color(0xFFFFC107), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: seleccionada ? Colors.white : const Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: Icon(
                categoria['icono'],
                color: seleccionada ? const Color(0xFF4CAF50) : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                categoria['titulo'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: seleccionada ? Colors.black : Colors.black87,
                ),
              ),
            ),
            if (seleccionada)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
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