import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/eventos_provider.dart';
import '../../providers/mascotas_provider.dart';
import '../modulo_peso/widgets/calendario_selector.dart';
import 'seleccion_categoria_evento.dart';

class FormularioEvento extends StatefulWidget {
  final String tipoInicial;
  final Map<String,dynamic>? evento; // datos existentes
  final String? mascotaId;

  const FormularioEvento({Key? key, required this.tipoInicial, this.evento, this.mascotaId}) : super(key: key);

  @override
  State<FormularioEvento> createState() => _FormularioEventoState();
}

class _FormularioEventoState extends State<FormularioEvento> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  DateTime _fechaSeleccionada = DateTime.now();
  TimeOfDay _horaSeleccionada = TimeOfDay.now();
  bool _crearRecordatorio = false;
  bool _isLoading = false;
  String _tipoSeleccionado = '';
  int _minutosAntes = 30;
  String? _mascotaSeleccionada;
  final Color _greenColor = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
  _tipoSeleccionado = widget.tipoInicial;
  _mascotaSeleccionada = widget.mascotaId;
    if (widget.evento != null) {
      final e = widget.evento!;
      _tituloController.text = (e['titulo'] ?? '').toString();
      _descripcionController.text = (e['descripcion'] ?? '').toString();
      _fechaSeleccionada = DateTime.tryParse(e['fecha']?.toString() ?? '') ?? DateTime.now();
      // Extraer hora si existe
      if (e['hora'] != null) {
        try {
          final partes = e['hora'].toString().split(':');
          if (partes.length >= 2) {
            _horaSeleccionada = TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1]));
          }
        } catch (_) {}
      }
  _crearRecordatorio = (e['recordatorio']?['activo'] == true) || (e['tieneRecordatorio'] == true);
  final rec = e['recordatorio'];
  if (rec is Map && rec['tiempoAntes'] is int) _minutosAntes = rec['tiempoAntes'];
  if (e['tipo'] != null) _tipoSeleccionado = e['tipo'];
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _greenColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
      });
    }
  }

  Future<void> _cambiarTipo() async {
    final String? nuevo = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const SeleccionCategoriaEvento(),
      ),
    );
    if (nuevo != null) setState(() => _tipoSeleccionado = nuevo);
  }

  Future<void> _seleccionarMascotaSiNecesario() async {
    if (_mascotaSeleccionada != null) return;
    final mascotasProv = context.read<MascotasProvider>();
    if (mascotasProv.mascotas.isEmpty) await mascotasProv.cargarMascotas(forzar: true);
    final lista = mascotasProv.mascotas;
    if (lista.isEmpty) return;
    if (lista.length == 1) {
      _mascotaSeleccionada = (lista.first['_id'] ?? lista.first['id']).toString();
      return;
    }
    final seleccion = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seleccionar mascota'),
        content: SizedBox(
          width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: lista.map((m) {
                final nombre = (m['nombre'] ?? '').toString();
                final id = (m['_id'] ?? m['id']).toString();
                return ListTile(
                  title: Text(nombre),
                  onTap: () => Navigator.pop(ctx, id),
                );
              }).toList(),
            ),
        ),
      ),
    );
    if (seleccion != null) setState(() => _mascotaSeleccionada = seleccion);
  }

  Future<void> _guardarEvento() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final prov = context.read<EventosProvider>();
      // Combinar fecha y hora seleccionadas
      final fecha = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day,
        _horaSeleccionada.hour,
        _horaSeleccionada.minute,
      );
      final hora = DateFormat('HH:mm').format(fecha);
      if (widget.evento == null) {
        await _seleccionarMascotaSiNecesario();
        final mascotaId = _mascotaSeleccionada;
        if (mascotaId == null) throw 'Selecciona una mascota';
        final ok = await prov.crear(
          mascotaId: mascotaId,
          titulo: _tituloController.text.trim(),
          tipo: _tipoSeleccionado,
          fecha: fecha,
          hora: hora,
          descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
          recordatorioActivo: _crearRecordatorio,
          minutosAntes: _minutosAntes,
        );
        if (!ok) throw prov.error ?? 'Error al crear';
      } else {
        final id = widget.evento!['_id'] ?? widget.evento!['id'];
        final ok = await prov.actualizar(id, {
          'titulo': _tituloController.text.trim(),
          'tipo': _tipoSeleccionado,
          'fecha': fecha,
          'hora': hora,
          'descripcion': _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
          'recordatorioActivo': _crearRecordatorio,
          'minutosAntes': _minutosAntes,
        });
        if (!ok) throw prov.error ?? 'Error al actualizar';
      }
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.evento == null ? 'Evento guardado exitosamente' : 'Evento actualizado'),
        backgroundColor: _greenColor,
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black54),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _greenColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Fecha del evento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: _seleccionarFecha,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat('d \'de\' MMM, yyyy').format(_fechaSeleccionada),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _seleccionarHora,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _horaSeleccionada.format(context),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Icon(Icons.access_time, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 1, 16, 16), // Menos padding superior
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del perro pintando
              Center(
                child: Container(
                  width: 350,
                  height: 350,
                  margin: const EdgeInsets.only(bottom: 2), // Menos margen inferior
                  child: Image.asset(
                    'assets/images/perro_evento_2.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(140),
                        ),
                        child: const Icon(
                          Icons.event,
                          size: 120,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Campo: Recordatorio/Título
              _buildTextField(
                controller: _tituloController,
                label: 'Recordatorio',
                hint: 'Título del evento',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa un título para el evento';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 8),
              
              // Campo: Fecha
              _buildDateField(),
              
              const SizedBox(height: 8),
              
              // Campo: Descripción
              _buildTextField(
                controller: _descripcionController,
                label: 'Descripción (opcional)',
                hint: 'Agrega detalles del evento...',
                maxLines: 3,
              ),
              
              const SizedBox(height: 16),
              
              // Botón para cambiar categoría
              GestureDetector(
                onTap: _cambiarTipo,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _greenColor.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIconoCategoria(_tipoSeleccionado),
                        color: _greenColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tipo: $_tipoSeleccionado',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.edit,
                        color: _greenColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Selector minutos antes (si recordatorio activo)
              if (_crearRecordatorio) Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.black54),
                    const SizedBox(width: 12),
                    const Text('Avisar antes:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: _minutosAntes,
                      underline: const SizedBox(),
                      items: const [5,10,15,30,45,60].map((m) => DropdownMenuItem(
                        value: m,
                        child: Text('$m min'),
                      )).toList(),
                      onChanged: (v) { if (v!=null) setState(()=>_minutosAntes=v); },
                    ),
                  ],
                ),
              ),

              SwitchListTile(
                value: _crearRecordatorio,
                title: const Text('Recordatorio activo'),
                activeColor: _greenColor,
                onChanged: (v) => setState(() => _crearRecordatorio = v),
                contentPadding: EdgeInsets.zero,
              ),
              
              const SizedBox(height: 32),
              
              // Botón Crear/Actualizar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarEvento,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _greenColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.evento != null ? 'Actualizar' : 'Crear',
                          style: const TextStyle(
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

  IconData _getIconoCategoria(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'paseo':
        return Icons.directions_walk;
      case 'juego':
        return Icons.sports_basketball;
      case 'comida':
        return Icons.restaurant;
      case 'alimentacion':
        return Icons.restaurant_menu;
      case 'baño':
        return Icons.bathtub;
      case 'veterinario':
        return Icons.local_hospital;
      case 'entrenamiento':
        return Icons.school;
      case 'ejercicio':
        return Icons.fitness_center;
      case 'socialización':
        return Icons.group;
      case 'descanso':
        return Icons.bed;
      case 'medicamento':
        return Icons.medical_services;
      case 'otro':
        return Icons.event_note;
      default:
        return Icons.event;
    }
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