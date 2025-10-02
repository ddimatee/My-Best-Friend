import 'package:flutter/material.dart';
import '../modulo_general/widgets/bottom_nav_global.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/mascotas_provider.dart';
import 'formulario_descripcion_calendario.dart';
import 'detalle_recordatorio_calendario.dart';
import 'servicios/calendario_service.dart';
import 'modelos/evento_calendario.dart';

class CalendarioModuloPantalla extends StatefulWidget {
  final Map<String, dynamic>? mascota; // Información de la mascota seleccionada
  
  const CalendarioModuloPantalla({Key? key, this.mascota}) : super(key: key);

  @override
  State<CalendarioModuloPantalla> createState() => _CalendarioModuloPantallaState();
}

class _CalendarioModuloPantallaState extends State<CalendarioModuloPantalla> with WidgetsBindingObserver {
  final Color _greenColor = const Color(0xFF4CAF50); // Verde consistente con la app
  List<EventoCalendario> _recordatorios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargarRecordatorios();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recargar cuando la app vuelve al primer plano
      _cargarRecordatorios();
    }
  }
  
  // Método que se llama cuando la ruta vuelve a estar visible
  @override
  void didUpdateWidget(CalendarioModuloPantalla oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recargar si cambió la mascota
    if (oldWidget.mascota != widget.mascota) {
      _cargarRecordatorios();
    }
  }

  Future<void> _cargarRecordatorios() async {
    try {
      final recordatorios = await CalendarioService.obtenerEventos();
      print('📅 Total recordatorios cargados: ${recordatorios.length}');
      
      // Filtrar recordatorios por mascota si hay una mascota seleccionada
      List<EventoCalendario> recordatoriosFiltrados = recordatorios;
      if (widget.mascota != null) {
        final mascotaId = widget.mascota!['_id']?.toString() ?? widget.mascota!['id']?.toString();
        print('🐕 Mascota ID para filtrar: $mascotaId');
        print('🐕 Mascota nombre: ${widget.mascota!['nombre']}');
        // Intentar migrar eventos legacy sin mascotaId asignándolos a la mascota activa
        if (mascotaId != null) {
          final migrados = await CalendarioService.migrarEventosSinMascota(
            mascotaId: mascotaId,
            mascotaNombre: widget.mascota!['nombre']?.toString(),
            mascotaFoto: widget.mascota!['foto']?.toString(),
          );
          if (migrados > 0) {
            print('🔄 Migrados $migrados eventos legacy a la mascota $mascotaId');
          }
        }
        
        recordatoriosFiltrados = recordatorios.where((recordatorio) {
          print('📝 Recordatorio: ${recordatorio.descripcion}, MascotaID: ${recordatorio.mascotaId}');
          // Mostrar también recordatorios legacy (mascotaId null) para que el usuario pueda editarlos y asignar mascota.
          final coincide = recordatorio.mascotaId == mascotaId;
          final legacy = recordatorio.mascotaId == null; 
          if (legacy) {
            print('⚠️  Recordatorio legacy sin mascotaId, se mostrará temporalmente.');
          }
          return coincide || legacy;
        }).toList();
        
        print('🔍 Recordatorios filtrados para ${widget.mascota!['nombre']}: ${recordatoriosFiltrados.length}');
      }
      
      setState(() {
        _recordatorios = recordatoriosFiltrados;
        _cargando = false;
      });
    } catch (e) {
      print('❌ Error cargando recordatorios: $e');
      setState(() {
        _cargando = false;
      });
    }
  }

  void _navegarAFormulario() async {
    HapticFeedback.lightImpact();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioDescripcionCalendario(
          mascota: widget.mascota,
        ),
      ),
    );
    
    // Siempre recargar después de regresar del formulario
    print('🔄 Recargando recordatorios después de volver del formulario...');
    await _cargarRecordatorios();
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
      'vacunas': const Color(0xFF1976D2), // Azul más oscuro para contraste
      'medicamentos': const Color(0xFFD32F2F), // Rojo más oscuro
      'alimentacion': const Color(0xFFFF8F00), // Ámbar oscuro
      'ejercicio': const Color(0xFF7B1FA2), // Morado oscuro
      'citas_veterinario': const Color(0xFFC2185B), // Rosa oscuro
      'aseo': const Color(0xFF0097A7), // Cian oscuro
      'juegos': const Color(0xFF689F38), // Verde oliva
      'otro': const Color(0xFF455A64), // Gris azulado oscuro
    };
    return colores[categoria] ?? const Color(0xFF424242);
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
          onPressed: () {
            // Regresar al menú principal (primera pantalla con bottom navigation)
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.mascota != null 
                ? 'Recordatorios de ${widget.mascota!['nombre']}'
                : 'Calendario',
            style: const TextStyle(
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
      
      // Barra inferior global (pantalla del módulo Calendario)
  bottomNavigationBar: const BottomNavGlobal(selectedIndex: 0),
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
            margin: const EdgeInsets.only(bottom: 20), // Reducido de 40 a 20
            child: Image.asset(
              'assets/images/perro_calendario.png', // Cambiado de perro_evento.png
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
    // Resolver nombre actual de la mascota si existe en provider (para reflejar renombres)
    String? nombreMascotaActual = recordatorio.mascotaNombre;
    if (recordatorio.mascotaId != null) {
      try {
        final prov = Provider.of<MascotasProvider>(context, listen: false);
        final m = prov.buscarPorId(recordatorio.mascotaId!);
        if (m != null && (m['nombre']?.toString().isNotEmpty ?? false)) {
          nombreMascotaActual = m['nombre'].toString();
        }
      } catch (_) {}
    }
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
                      
                      // Categoría y mascota
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        runSpacing: 0,
                        children: [
                          Text(
                            nombreCategoria,
                            style: TextStyle(
                              fontSize: 13,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (nombreMascotaActual != null && nombreMascotaActual.trim().isNotEmpty)
                            Text(
                              '• $nombreMascotaActual',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 2),
                      
                      // Hora
                      Text(
                        hora, // Ya viene formateada (24h) desde arriba
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

// Clase _BottomItem eliminada (se usa BottomNavGlobal)