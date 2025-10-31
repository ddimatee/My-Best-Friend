import 'package:flutter/material.dart';
import 'configuracion_recordatorio_calendario.dart';
import 'modelos/evento_calendario.dart';

class OpcionesProgramacionCalendario extends StatefulWidget {
  final String descripcion;
  final String categoria;
  final EventoCalendario? recordatorioParaEditar; // Recordatorio a editar (opcional)
  final Map<String, dynamic>? mascota; // Información de la mascota seleccionada
  
  const OpcionesProgramacionCalendario({
    Key? key, 
    required this.descripcion,
    required this.categoria,
    this.recordatorioParaEditar,
    this.mascota,
  }) : super(key: key);

  @override
  State<OpcionesProgramacionCalendario> createState() => _OpcionesProgramacionCalendarioState();
}

class _OpcionesProgramacionCalendarioState extends State<OpcionesProgramacionCalendario> {
  final Color _greenColor = const Color(0xFF4CAF50); // Verde consistente con la app
  final Color _grayColor = const Color(0xFFE5E5E5);
  String? _opcionSeleccionada;

  final List<Map<String, dynamic>> _opciones = [
    {
      'id': 'una_vez',
      'titulo': 'Una sola vez',
      'descripcion': 'Te preguntaremos: ¿Para qué fecha específica quieres este recordatorio?',
      'icono': Icons.schedule,
    },
    {
      'id': 'diario',
      'titulo': 'Diario',
      'descripcion': 'Te preguntaremos: ¿A qué hora todos los días quieres el recordatorio?',
      'icono': Icons.today,
    },
    {
      'id': 'semanal',
      'titulo': 'Semanal',
      'descripcion': 'Te preguntaremos: ¿Qué días de la semana y a qué hora?',
      'icono': Icons.view_week,
    },
    {
      'id': 'mensual',
      'titulo': 'Mensual',
      'descripcion': 'Te preguntaremos: ¿Qué día del mes y a qué hora cada mes?',
      'icono': Icons.calendar_view_month,
    },
    {
      'id': 'personalizado',
      'titulo': 'Personalizado',
      'descripcion': 'Te preguntaremos: ¿Cada cuántos días/semanas/meses y en qué rangos?',
      'icono': Icons.tune,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Si estamos editando, precargar la frecuencia existente
    if (widget.recordatorioParaEditar != null) {
      _opcionSeleccionada = widget.recordatorioParaEditar!.frecuencia;
    }
  }

  void _seleccionarOpcion(String opcion) {
    setState(() {
      _opcionSeleccionada = opcion;
    });
  }

  void _continuar() {
    if (_opcionSeleccionada != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfiguracionRecordatorioCalendario(
            descripcion: widget.descripcion,
            categoria: widget.categoria,
            frecuencia: _opcionSeleccionada!,
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
                'Opciones de programación',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          
          // Cuerpo verde con opciones
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  
                  const Text(
                    'Elige cómo quieres programar tu recordatorio.\nCada opción te pedirá información específica:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  ..._opciones.map((opcion) => Column(
                    children: [
                      _OpcionItem(
                        opcion: opcion,
                        seleccionada: _opcionSeleccionada == opcion['id'],
                        onTap: () => _seleccionarOpcion(opcion['id']),
                      ),
                      const SizedBox(height: 16),
                    ],
                  )),
                  
                  const SizedBox(height: 40),
                  
                  // Botón Continuar
                  if (_opcionSeleccionada != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _continuar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black,
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
          ),
        ],
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

class _OpcionItem extends StatelessWidget {
  final Map<String, dynamic> opcion;
  final bool seleccionada;
  final VoidCallback onTap;

  const _OpcionItem({
    required this.opcion,
    required this.seleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: seleccionada ? const Color(0xFFFFC107) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: seleccionada 
              ? Border.all(color: const Color(0xFFFFC107), width: 2)
              : Border.all(color: Colors.grey.shade300, width: 1),
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
                opcion['icono'],
                color: seleccionada ? const Color(0xFF4CAF50) : Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opcion['titulo'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: seleccionada ? Colors.black : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    opcion['descripcion'],
                    style: TextStyle(
                      fontSize: 14,
                      color: seleccionada ? Colors.black.withOpacity(0.8) : Colors.black54,
                    ),
                  ),
                ],
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