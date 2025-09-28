import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'servicios/calendario_service.dart';
import 'modelos/evento_calendario.dart';
import 'formulario_descripcion_calendario.dart';

class DetalleRecordatorioCalendario extends StatefulWidget {
  final EventoCalendario recordatorio;

  const DetalleRecordatorioCalendario({Key? key, required this.recordatorio}) : super(key: key);

  @override
  State<DetalleRecordatorioCalendario> createState() => _DetalleRecordatorioCalendarioState();
}

class _DetalleRecordatorioCalendarioState extends State<DetalleRecordatorioCalendario> {
  final Color _greenColor = const Color(0xFF2196F3); // Azul más visible

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
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    
    return '${fechaHora.day} de ${meses[fechaHora.month - 1]} de ${fechaHora.year}';
  }

  String _formatearHora(DateTime fechaHora) {
    final hora = fechaHora.hour.toString().padLeft(2, '0');
    final minutos = fechaHora.minute.toString().padLeft(2, '0');
    return '$hora:$minutos';
  }

  String _obtenerNombreFrecuencia(String frecuencia) {
    final frecuencias = {
      'una_vez': 'Una sola vez',
      'diario': 'Diario',
      'semanal': 'Semanal',
      'mensual': 'Mensual',
      'personalizado': 'Personalizado',
    };
    return frecuencias[frecuencia] ?? frecuencia;
  }

  void _modificarRecordatorio() async {
    HapticFeedback.lightImpact();
    
    // Por simplicidad, navegar al formulario de descripción
    // En un app más complejo, tendríamos un formulario de edición específico
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormularioDescripcionCalendario(),
      ),
    );
    
    if (resultado == true) {
      Navigator.pop(context, true); // Regresar con cambios
    }
  }

  void _eliminarRecordatorio() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              const Text('Confirmar eliminación'),
            ],
          ),
          content: const Text(
            '¿Estás seguro de que quieres eliminar este recordatorio? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmado == true) {
      try {
        await CalendarioService.eliminarEvento(widget.recordatorio.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recordatorio eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true); // Regresar con cambios
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _obtenerColorCategoria(widget.recordatorio.categoria);
    
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
        title: const Text(
          'Detalle del recordatorio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta principal del recordatorio
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icono y categoría
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _obtenerIconoCategoria(widget.recordatorio.categoria),
                      size: 48,
                      color: color,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Título/Descripción
                  Text(
                    widget.recordatorio.descripcion,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Categoría
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _obtenerNombreCategoria(widget.recordatorio.categoria),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Información detallada
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información del recordatorio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _DetalleItem(
                    icono: Icons.calendar_today,
                    titulo: 'Fecha',
                    valor: _formatearFechaHora(widget.recordatorio.fechaHora),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _DetalleItem(
                    icono: Icons.access_time,
                    titulo: 'Hora',
                    valor: '${_formatearHora(widget.recordatorio.fechaHora)} PM',
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _DetalleItem(
                    icono: Icons.repeat,
                    titulo: 'Frecuencia',
                    valor: _obtenerNombreFrecuencia(widget.recordatorio.frecuencia),
                  ),
                  
                  if (widget.recordatorio.avisos.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _DetalleItem(
                      icono: Icons.notifications,
                      titulo: 'Recordatorio',
                      valor: widget.recordatorio.avisos.first.descripcion,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _modificarRecordatorio,
                    icon: const Icon(Icons.edit),
                    label: const Text('Modificar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _eliminarRecordatorio,
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
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

class _DetalleItem extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _DetalleItem({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, size: 20, color: const Color(0xFF2196F3)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
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