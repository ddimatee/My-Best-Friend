import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'formulario_descripcion_calendario.dart';
import 'detalle_recordatorio_calendario.dart';
import 'servicios/calendario_service.dart';
import 'modelos/evento_calendario.dart';

class CalendarioModuloPantalla extends StatefulWidget {
  const CalendarioModuloPantalla({Key? key}) : super(key: key);

  @override
  State<CalendarioModuloPantalla> createState() => _CalendarioModuloPantallaState();
}

class _CalendarioModuloPantallaState extends State<CalendarioModuloPantalla> {
  final Color _greenColor = const Color(0xFF2196F3); // Azul más visible
  List<EventoCalendario> _recordatorios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarRecordatorios();
  }

  Future<void> _cargarRecordatorios() async {
    try {
      final recordatorios = await CalendarioService.obtenerEventos();
      setState(() {
        _recordatorios = recordatorios;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
      });
    }
  }

  void _navegarAFormulario() async {
    HapticFeedback.lightImpact();
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormularioDescripcionCalendario(),
      ),
    );
    
    if (resultado == true) {
      _cargarRecordatorios(); // Recargar la lista si se guardó algo
    }
  }

  void _navegarADetalle(EventoCalendario recordatorio) async {
    HapticFeedback.selectionClick();
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleRecordatorioCalendario(recordatorio: recordatorio),
      ),
    );
    
    if (resultado == true) {
      _cargarRecordatorios(); // Recargar si hubo cambios
    }
  }

  String _obtenerNombreCategoria(String categoria) {
    final categorias = {
      'vacunas': 'Vacunas',
      'medicamentos': 'Medicamentos',
      'alimentacion': 'Alimentación',
      'ejercicio': 'Ejercicio',
      'citas_veterinario': 'Citas con el veterinario',
      'aseo': 'Aseo',
      'juegos': 'Juegos y entretenimiento',
      'otro': 'Otro',
    };
    return categorias[categoria] ?? categoria;
  }

  IconData _obtenerIconoCategoria(String categoria) {
    final iconos = {
      'vacunas': Icons.vaccines,
      'medicamentos': Icons.medication,
      'alimentacion': Icons.restaurant,
      'ejercicio': Icons.directions_run,
      'citas_veterinario': Icons.local_hospital,
      'aseo': Icons.bathtub,
      'juegos': Icons.sports_soccer,
      'otro': Icons.more_horiz,
    };
    return iconos[categoria] ?? Icons.event;
  }

  Color _obtenerColorCategoria(String categoria) {
    final colores = {
      'vacunas': const Color(0xFF2196F3), // Azul
      'medicamentos': const Color(0xFFFF5722), // Naranja rojizo
      'alimentacion': const Color(0xFFFF9800), // Naranja
      'ejercicio': const Color(0xFF9C27B0), // Morado
      'citas_veterinario': const Color(0xFFE91E63), // Rosa
      'aseo': const Color(0xFF00BCD4), // Cian
      'juegos': const Color(0xFF8BC34A), // Verde claro
      'otro': const Color(0xFF607D8B), // Gris azulado
    };
    return colores[categoria] ?? const Color(0xFF757575);
  }

  String _formatearFechaHora(DateTime fechaHora) {
    final meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    
    return '${fechaHora.day} de ${meses[fechaHora.month - 1]} de ${fechaHora.year}';
  }

  String _formatearHora(DateTime fechaHora) {
    final hora = fechaHora.hour.toString().padLeft(2, '0');
    final minutos = fechaHora.minute.toString().padLeft(2, '0');
    return '$hora:$minutos';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greenColor,
      appBar: AppBar(
        backgroundColor: _greenColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Calendario',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      body: _cargando 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _recordatorios.isEmpty 
              ? _buildEstadoVacio()
              : _buildListaRecordatorios(),
      
      // Botón flotante para crear nuevo recordatorio
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarAFormulario,
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text(
          'Crear',
          style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            margin: const EdgeInsets.only(bottom: 40),
            child: Image.asset(
              'assets/images/perro_evento.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    size: 80,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
          
          const Text(
            '¡Registra algo en\nel Calendario!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaRecordatorios() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: _recordatorios.length,
        itemBuilder: (context, index) {
          final recordatorio = _recordatorios[index];
          return _RecordatorioCard(
            recordatorio: recordatorio,
            onTap: () => _navegarADetalle(recordatorio),
            nombreCategoria: _obtenerNombreCategoria(recordatorio.categoria),
            icono: _obtenerIconoCategoria(recordatorio.categoria),
            color: _obtenerColorCategoria(recordatorio.categoria),
            fecha: _formatearFechaHora(recordatorio.fechaHora),
            hora: _formatearHora(recordatorio.fechaHora),
          );
        },
      ),
    );
  }
}

class _RecordatorioCard extends StatelessWidget {
  final EventoCalendario recordatorio;
  final VoidCallback onTap;
  final String nombreCategoria;
  final IconData icono;
  final Color color;
  final String fecha;
  final String hora;

  const _RecordatorioCard({
    required this.recordatorio,
    required this.onTap,
    required this.nombreCategoria,
    required this.icono,
    required this.color,
    required this.fecha,
    required this.hora,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icono de la categoría
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icono,
                    color: color,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Contenido principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y categoría
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recordatorio.descripcion,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Fecha
                      Text(
                        fecha,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 2),
                      
                      // Hora
                      Text(
                        '$hora PM',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Etiqueta de categoría
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    nombreCategoria,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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