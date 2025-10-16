import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificacionesPantalla extends StatefulWidget {
  const NotificacionesPantalla({Key? key}) : super(key: key);

  @override
  State<NotificacionesPantalla> createState() => _NotificacionesPantallaState();
}

class _NotificacionesPantallaState extends State<NotificacionesPantalla> {
  bool _notificacionesGenerales = true;
  bool _recordatoriosVacunas = true;
  bool _recordatoriosPeso = false;
  bool _recordatoriosEventos = true;
  bool _recordatoriosAlimentacion = true;
  bool _actualizacionesApp = false;

  String _frecuenciaRecordatorios = 'Diaria';
  String _horaRecordatorios = '09:00 AM';

  @override
  void initState() {
    super.initState();
    _cargarConfiguracionPersistida();
  }

  Future<void> _cargarConfiguracionPersistida() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificacionesGenerales = prefs.getBool('notif_generales') ?? _notificacionesGenerales;
        _recordatoriosVacunas = prefs.getBool('notif_vacunas') ?? _recordatoriosVacunas;
        _recordatoriosPeso = prefs.getBool('notif_peso') ?? _recordatoriosPeso;
        _recordatoriosEventos = prefs.getBool('notif_eventos') ?? _recordatoriosEventos;
        _recordatoriosAlimentacion = prefs.getBool('notif_alimentacion') ?? _recordatoriosAlimentacion;
        _actualizacionesApp = prefs.getBool('notif_actualizaciones') ?? _actualizacionesApp;
        _frecuenciaRecordatorios = prefs.getString('notif_frecuencia') ?? _frecuenciaRecordatorios;
        _horaRecordatorios = prefs.getString('notif_hora') ?? _horaRecordatorios;
      });
      // Reprogramar recordatorios relevantes si estaban activos
      if (_notificacionesGenerales) {
        await _aplicarProgramacionRecordatorios();
      }
    } catch (_) {
      // Silencio: si falla la carga no se rompe la pantalla
    }
  }

  Future<void> _aplicarProgramacionRecordenariosPeso() async {
    // Placeholder para recordatorios de peso (ejemplo simple diario a la hora configurada)
    // En una implementación real, programarías con NotificationService.
    // Omitido por simplicidad mientras no haya lógica de peso.
  }

  Future<void> _aplicarProgramacionRecordatorios() async {
    if (!_notificacionesGenerales) return;
    // Aquí podrías cancelar primero (según necesidades) y luego reprogramar.
    if (_recordatoriosPeso) {
      await _aplicarProgramacionRecordenariosPeso();
    }
    // Se podrían añadir: vacunas, eventos, alimentación.
  }

  @override
  Widget build(BuildContext context) {
    final Color green = const Color(0xFF4CAF50);
    
    return Scaffold(
      backgroundColor: green,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección General
                const Text(
                  'General',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildSwitchTile(
                  'Activar todas las notificaciones',
                  'Recibir notificaciones de la aplicación',
                  _notificacionesGenerales,
                  Icons.notifications_outlined,
                  (value) async {
                    setState(() => _notificacionesGenerales = value);
                    await _persistir();
                    if (!value) {
                      // Apagar todas implica cancelar programaciones
                      // (Aquí podríamos llamar a NotificationService().cancelAll(); si se decide globalmente)
                    } else {
                      await _aplicarProgramacionRecordatorios();
                    }
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Sección Recordatorios
                const Text(
                  'Recordatorios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildSwitchTile(
                  'Vacunas',
                  'Recordatorios de citas de vacunación',
                  _recordatoriosVacunas,
                  Icons.medical_services_outlined,
                  (value) async {
                    setState(() => _recordatoriosVacunas = value);
                    await _persistir();
                    await _aplicarProgramacionRecordatorios();
                  },
                  enabled: _notificacionesGenerales,
                ),
                
                _buildSwitchTile(
                  'Control de peso',
                  'Recordatorios para registrar el peso',
                  _recordatoriosPeso,
                  Icons.monitor_weight_outlined,
                  (value) async {
                    setState(() => _recordatoriosPeso = value);
                    await _persistir();
                    await _aplicarProgramacionRecordatorios();
                  },
                  enabled: _notificacionesGenerales,
                ),
                
                _buildSwitchTile(
                  'Eventos',
                  'Recordatorios de eventos programados',
                  _recordatoriosEventos,
                  Icons.event_outlined,
                  (value) async {
                    setState(() => _recordatoriosEventos = value);
                    await _persistir();
                    await _aplicarProgramacionRecordatorios();
                  },
                  enabled: _notificacionesGenerales,
                ),
                
                _buildSwitchTile(
                  'Alimentación',
                  'Recordatorios de horarios de comida',
                  _recordatoriosAlimentacion,
                  Icons.restaurant_outlined,
                  (value) async {
                    setState(() => _recordatoriosAlimentacion = value);
                    await _persistir();
                    await _aplicarProgramacionRecordatorios();
                  },
                  enabled: _notificacionesGenerales,
                ),

                const SizedBox(height: 24),
                
                // Configuración de horarios
                const Text(
                  'Configuración de horarios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildDropdownTile(
                  'Frecuencia de recordatorios',
                  _frecuenciaRecordatorios,
                  ['Diaria', 'Semanal', 'Personalizada'],
                  Icons.repeat,
                  (value) async {
                    setState(() => _frecuenciaRecordatorios = value!);
                    await _persistir();
                    await _aplicarProgramacionRecordatorios();
                  },
                  enabled: _notificacionesGenerales,
                ),
                
                const SizedBox(height: 16),
                
                _buildTimeTile(
                  'Hora de recordatorios',
                  _horaRecordatorios,
                  Icons.access_time,
                  enabled: _notificacionesGenerales,
                ),
                
                const SizedBox(height: 24),
                
                // Sección Aplicación
                const Text(
                  'Aplicación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildSwitchTile(
                  'Actualizaciones',
                  'Notificaciones sobre nuevas versiones',
                  _actualizacionesApp,
                  Icons.system_update_outlined,
                  (value) async { setState(() => _actualizacionesApp = value); await _persistir(); },
                  enabled: _notificacionesGenerales,
                ),
                
                const SizedBox(height: 30),
                
                // Botón Guardar
                // Botón ya opcional; autosave implementado. Se deja por feedback visual.
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _guardarConfiguracionNotificaciones,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Guardar Configuración',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String titulo,
    String descripcion,
    bool valor,
    IconData icono,
    Function(bool) onChanged, {bool enabled = true}
  ) {
    final visualDisabled = !enabled;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50.withOpacity(enabled ? 1 : 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icono,
            color: visualDisabled ? Colors.grey.shade400 : Colors.grey.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: TextStyle(
                    fontSize: 13,
                    color: visualDisabled ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: valor,
            onChanged: enabled ? onChanged : null,
            activeColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String titulo,
    String valorActual,
    List<String> opciones,
    IconData icono,
    Function(String?) onChanged, {bool enabled = true}
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50.withOpacity(enabled ? 1 : 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icono,
            color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          DropdownButton<String>(
            value: valorActual,
            onChanged: enabled ? onChanged : null,
            underline: Container(),
            items: opciones.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(String titulo, String hora, IconData icono, {bool enabled = true}) {
    return GestureDetector(
      onTap: () => enabled ? _seleccionarHora() : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50.withOpacity(enabled ? 1 : 0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              icono,
              color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              hora,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: enabled ? Colors.grey.shade400 : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  void _seleccionarHora() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (hora != null) {
      setState(() {
        _horaRecordatorios = hora.format(context);
      });
    }
  }

  void _guardarConfiguracionNotificaciones() {
    _persistir();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración de notificaciones guardada'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _persistir() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notif_generales', _notificacionesGenerales);
      await prefs.setBool('notif_vacunas', _recordatoriosVacunas);
      await prefs.setBool('notif_peso', _recordatoriosPeso);
      await prefs.setBool('notif_eventos', _recordatoriosEventos);
      await prefs.setBool('notif_alimentacion', _recordatoriosAlimentacion);
      await prefs.setBool('notif_actualizaciones', _actualizacionesApp);
      await prefs.setString('notif_frecuencia', _frecuenciaRecordatorios);
      await prefs.setString('notif_hora', _horaRecordatorios);
    } catch (_) {
      // Ignorar errores silenciosamente
    }
  }
}