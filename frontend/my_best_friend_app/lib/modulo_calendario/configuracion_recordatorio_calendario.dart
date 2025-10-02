import 'package:flutter/material.dart';
import '../modulo_general/widgets/bottom_nav_global.dart';
import '../modulo_peso/widgets/calendario_selector.dart';
import 'configuracion_avanzada_calendario.dart';
import 'modelos/evento_calendario.dart';

class ConfiguracionRecordatorioCalendario extends StatefulWidget {
  final String descripcion;
  final String categoria;
  final String frecuencia;
  final EventoCalendario? recordatorioParaEditar; // Recordatorio a editar (opcional)
  final Map<String, dynamic>? mascota; // Información de la mascota seleccionada
  
  const ConfiguracionRecordatorioCalendario({
    Key? key, 
    required this.descripcion,
    required this.categoria,
    required this.frecuencia,
    this.recordatorioParaEditar,
    this.mascota,
  }) : super(key: key);

  @override
  State<ConfiguracionRecordatorioCalendario> createState() => _ConfiguracionRecordatorioCalendarioState();
}

class _ConfiguracionRecordatorioCalendarioState extends State<ConfiguracionRecordatorioCalendario> {
  final Color _greenColor = const Color(0xFF4CAF50); // Verde consistente con la app
  final Color _grayColor = const Color(0xFFE5E5E5);
  
  DateTime _fechaSeleccionada = DateTime.now();
  TimeOfDay _horaSeleccionada = TimeOfDay.now();
  bool _notificacionActivada = true;
  String _tipoNotificacion = 'push';
  int _minutosAntes = 15;

  @override
  void initState() {
    super.initState();
    // Si estamos editando, precargar los datos existentes
    if (widget.recordatorioParaEditar != null) {
      final recordatorio = widget.recordatorioParaEditar!;
      _fechaSeleccionada = DateTime(recordatorio.fechaHora.year, recordatorio.fechaHora.month, recordatorio.fechaHora.day);
      _horaSeleccionada = TimeOfDay(hour: recordatorio.fechaHora.hour, minute: recordatorio.fechaHora.minute);
      _notificacionActivada = recordatorio.avisos.isNotEmpty;
      
      // Buscar el tipo de aviso para configurar notificaciones
      if (recordatorio.avisos.isNotEmpty) {
        final primerAviso = recordatorio.avisos.first;
        if (primerAviso.tipo == 'a_la_hora') {
          _tipoNotificacion = 'push';
          _minutosAntes = 0;
        } else if (primerAviso.tipo == 'antes_de') {
          _tipoNotificacion = 'push';
          _minutosAntes = primerAviso.minutos;
        }
      }
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await mostrarCalendarioPeso(
      context: context,
      fechaInicial: _fechaSeleccionada,
    );
    
    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
    );
    
    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
      });
    }
  }

  void _continuar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfiguracionAvanzadaCalendario(
          descripcion: widget.descripcion,
          categoria: widget.categoria,
          frecuencia: widget.frecuencia,
          fecha: _fechaSeleccionada,
          hora: _horaSeleccionada,
          notificacionActivada: _notificacionActivada,
          tipoNotificacion: _tipoNotificacion,
          minutosAntes: _minutosAntes,
          recordatorioParaEditar: widget.recordatorioParaEditar,
          mascota: widget.mascota,
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return "${fecha.day}/${fecha.month}/${fecha.year}";
  }

  String _formatearHora(TimeOfDay hora) {
    return "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}";
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
                'Configurar recordatorio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          
          // Cuerpo verde con configuraciones
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fecha
                  _ConfiguracionItem(
                    titulo: 'Fecha',
                    valor: _formatearFecha(_fechaSeleccionada),
                    icono: Icons.calendar_today,
                    onTap: _seleccionarFecha,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Hora
                  _ConfiguracionItem(
                    titulo: 'Hora',
                    valor: _formatearHora(_horaSeleccionada),
                    icono: Icons.access_time,
                    onTap: _seleccionarHora,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notificación
                  Container(
                    padding: const EdgeInsets.all(16),
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
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notifications, size: 24, color: Color(0xFF4CAF50)),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Activar notificación',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Switch(
                              value: _notificacionActivada,
                              onChanged: (value) {
                                setState(() {
                                  _notificacionActivada = value;
                                });
                              },
                              activeColor: const Color(0xFF4CAF50),
                            ),
                          ],
                        ),
                        
                        if (_notificacionActivada) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          
                          // Tipo de notificación
                          Row(
                            children: [
                              const Text('Tipo: ', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(width: 8),
                              DropdownButton<String>(
                                value: _tipoNotificacion,
                                items: const [
                                  DropdownMenuItem(value: 'push', child: Text('Notificación push')),
                                  DropdownMenuItem(value: 'email', child: Text('Correo electrónico')),
                                  DropdownMenuItem(value: 'ambos', child: Text('Ambos')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _tipoNotificacion = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Minutos antes
                          Row(
                            children: [
                              const Text('Recordar: ', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(width: 8),
                              DropdownButton<int>(
                                value: _minutosAntes,
                                items: const [
                                  DropdownMenuItem(value: 0, child: Text('En el momento')),
                                  DropdownMenuItem(value: 5, child: Text('5 minutos antes')),
                                  DropdownMenuItem(value: 15, child: Text('15 minutos antes')),
                                  DropdownMenuItem(value: 30, child: Text('30 minutos antes')),
                                  DropdownMenuItem(value: 60, child: Text('1 hora antes')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _minutosAntes = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Botón Continuar
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
      
  bottomNavigationBar: const BottomNavGlobal(selectedIndex: -1),
    );
  }
}

class _ConfiguracionItem extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final VoidCallback onTap;

  const _ConfiguracionItem({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Icon(icono, size: 24, color: const Color(0xFF4CAF50)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

// _BottomItem eliminado (se usa BottomNavGlobal)