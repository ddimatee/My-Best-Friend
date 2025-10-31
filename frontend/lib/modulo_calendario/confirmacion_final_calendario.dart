import 'package:flutter/material.dart';
import 'servicios/calendario_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'modelos/evento_calendario.dart';

class ConfirmacionFinalCalendario extends StatefulWidget {
  final String descripcion;
  final String categoria;
  final String frecuencia;
  final DateTime fecha;
  final TimeOfDay hora;
  final bool notificacionActivada;
  final String tipoNotificacion;
  final int minutosAntes;
  final bool sonidoActivado;
  final bool vibracionActivada;
  final String prioridadNotificacion;
  final bool mostrarEnPantallaBloqueada;
  final String categoriaNotificacion;
  final bool repetirSiNoSeVe;
  final int intervalosRepeticion;
  final EventoCalendario? recordatorioParaEditar; // Recordatorio a editar (opcional)
  final Map<String, dynamic>? mascota; // Información de la mascota seleccionada
  
  const ConfirmacionFinalCalendario({
    Key? key,
    required this.descripcion,
    required this.categoria,
    required this.frecuencia,
    required this.fecha,
    required this.hora,
    required this.notificacionActivada,
    required this.tipoNotificacion,
    required this.minutosAntes,
    required this.sonidoActivado,
    required this.vibracionActivada,
    required this.prioridadNotificacion,
    required this.mostrarEnPantallaBloqueada,
    required this.categoriaNotificacion,
    required this.repetirSiNoSeVe,
    required this.intervalosRepeticion,
    this.recordatorioParaEditar,
    this.mascota,
  }) : super(key: key);

  @override
  State<ConfirmacionFinalCalendario> createState() => _ConfirmacionFinalCalendarioState();
}

class _ConfirmacionFinalCalendarioState extends State<ConfirmacionFinalCalendario> {
  final Color _greenColor = const Color(0xFF4CAF50); // Verde que combina con los recordatorios
  final Color _grayColor = const Color(0xFFE5E5E5);
  final CalendarioService _calendarioService = CalendarioService();
  bool _guardando = false;

  Future<void> _guardarEvento() async {
    setState(() {
      _guardando = true;
    });

    try {
      final auth = context.read<AuthProvider>();
      final userId = auth.user?['_id']?.toString();
      
      print('🐕 Widget mascota: ${widget.mascota}');
      print('🐕 Mascota ID intentando guardar: ${widget.mascota?['_id']} o ${widget.mascota?['id']}');
      
      // Si estamos editando, usar el ID existente; si no, crear uno nuevo
      final eventoId = widget.recordatorioParaEditar?.id ?? 
                      DateTime.now().millisecondsSinceEpoch.toString();
      
      final evento = EventoCalendario(
        id: eventoId,
        titulo: widget.descripcion,
        descripcion: widget.descripcion,
        categoria: widget.categoria,
        fechaHora: DateTime(
          widget.fecha.year,
          widget.fecha.month,
          widget.fecha.day,
          widget.hora.hour,
          widget.hora.minute,
        ),
        tipoRecordatorio: widget.frecuencia == 'una_vez' ? 'una_vez' : 'repetir',
        frecuencia: widget.frecuencia,
        avisos: widget.notificacionActivada ? [TipoAviso(
          tipo: widget.minutosAntes == 0 ? 'a_la_hora' : 'antes_de',
          minutos: widget.minutosAntes,
          descripcion: widget.minutosAntes == 0 
              ? 'A la hora' 
              : '${widget.minutosAntes} minutos antes',
        )] : [],
        activo: true,
        userId: userId,
        mascotaId: widget.mascota?['_id']?.toString() ?? widget.mascota?['id']?.toString(),
        mascotaNombre: widget.mascota?['nombre']?.toString(),
        mascotaFoto: widget.mascota?['foto']?.toString(),
      );

      print('💾 Guardando evento para mascota: ${evento.mascotaNombre}');
      print('💾 ID de mascota guardado: ${evento.mascotaId}');
      print('💾 Descripción: ${evento.descripcion}');

      if (widget.recordatorioParaEditar != null) {
        // Actualizar recordatorio existente
        final resultado = await CalendarioService.actualizarEvento(evento);
        if (!resultado) {
          throw Exception('No se pudo actualizar el recordatorio');
        }
      } else {
        // Crear nuevo recordatorio
        await _calendarioService.crearEvento(evento, currentUserId: userId);
      }
      
      // Mostrar mensaje de éxito
      final mensajeExito = widget.recordatorioParaEditar != null 
          ? '¡Recordatorio actualizado correctamente!'
          : '¡Recordatorio guardado correctamente!';
          
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeExito),
          backgroundColor: const Color(0xFF4CAF50), // Verde para mejor visibilidad
          duration: const Duration(seconds: 2),
        ),
      );

      // Regresar al módulo calendario después de guardar exitosamente
      if (mounted) {
        // Navegar de vuelta con un delay mínimo
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            // Simplemente hacer pop múltiple para volver
            Navigator.of(context)
              ..pop() // Salir de confirmación
              ..pop() // Salir de avanzada
              ..pop() // Salir de configuración
              ..pop() // Salir de opciones
              ..pop() // Salir de categoría
              ..pop(); // Salir de descripción
          }
        });
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _guardando = false;
      });
    }
  }

  String _formatearFechaHora() {
    return "${widget.fecha.day}/${widget.fecha.month}/${widget.fecha.year} a las ${widget.hora.hour.toString().padLeft(2, '0')}:${widget.hora.minute.toString().padLeft(2, '0')}";
  }

  String _obtenerNombreCategoria() {
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
    return categorias[widget.categoria] ?? widget.categoria;
  }

  String _obtenerNombreFrecuencia() {
    final frecuencias = {
      'una_vez': 'Una sola vez',
      'diario': 'Diario',
      'semanal': 'Semanal',
      'mensual': 'Mensual',
      'personalizado': 'Personalizado',
    };
    return frecuencias[widget.frecuencia] ?? widget.frecuencia;
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
                'Confirmar recordatorio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          
          // Cuerpo verde con resumen
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono de éxito
                  const Center(
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  const Center(
                    child: Text(
                      '¡Perfecto! Tu recordatorio está listo.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Center(
                    child: Text(
                      'Revisa los detalles antes de guardar:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Resumen del evento
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ResumenItem(
                          icono: Icons.description,
                          titulo: 'Descripción',
                          valor: widget.descripcion,
                        ),
                        const Divider(height: 24),
                        _ResumenItem(
                          icono: Icons.category,
                          titulo: 'Categoría',
                          valor: _obtenerNombreCategoria(),
                        ),
                        const Divider(height: 24),
                        _ResumenItem(
                          icono: Icons.schedule,
                          titulo: 'Fecha y hora',
                          valor: _formatearFechaHora(),
                        ),
                        const Divider(height: 24),
                        _ResumenItem(
                          icono: Icons.repeat,
                          titulo: 'Frecuencia',
                          valor: _obtenerNombreFrecuencia(),
                        ),
                        if (widget.notificacionActivada) ...[
                          const Divider(height: 24),
                          _ResumenItem(
                            icono: Icons.notifications,
                            titulo: 'Notificación',
                            valor: widget.minutosAntes == 0 
                                ? 'En el momento' 
                                : '${widget.minutosAntes} minutos antes',
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _guardando ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Modificar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _guardando ? null : _guardarEvento,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 2,
                          ),
                          child: _guardando
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Guardando...'),
                                  ],
                                )
                              : const Text(
                                  'Guardar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
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

class _ResumenItem extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _ResumenItem({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 20, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
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