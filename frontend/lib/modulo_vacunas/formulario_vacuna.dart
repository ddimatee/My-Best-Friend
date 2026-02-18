import 'package:flutter/material.dart';
import '../modulo_general/widgets/bottom_nav_global.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/vacunas_provider.dart';
import '../../providers/mascotas_provider.dart';
import '../modulo_peso/widgets/calendario_selector.dart';

class FormularioVacuna extends StatefulWidget {
  final Map<String, dynamic>? vacuna; // datos existentes para editar
  final String? mascotaIdFija;

  const FormularioVacuna({Key? key, this.vacuna, this.mascotaIdFija}) : super(key: key);

  @override
  State<FormularioVacuna> createState() => _FormularioVacunaState();
}

class _FormularioVacunaState extends State<FormularioVacuna> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ubicacionController = TextEditingController();
  String? _mascotaSeleccionadaId; // Mascota a la que se asignará la vacuna
  
  DateTime _fechaSeleccionada = DateTime.now();
  TimeOfDay _horaRecordatorio = TimeOfDay(hour: 9, minute: 0); // 9:00 AM por defecto
  bool _crearRecordatorio = false;
  bool _isLoading = false;
  final Color _greenColor = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    if (widget.vacuna != null) {
      final v = widget.vacuna!;
      _nombreController.text = (v['nombre'] ?? '').toString();
      _descripcionController.text = (v['observaciones'] ?? v['descripcion'] ?? '').toString();
      _ubicacionController.text = (v['ubicacion'] ?? '').toString();
      // Obtener id de mascota de la vacuna (puede venir como string o como objeto anidado)
      final mascotaData = v['mascota'] ?? v['mascotaId'];
      if (mascotaData is Map) {
        _mascotaSeleccionadaId = (mascotaData['_id'] ?? mascotaData['id'])?.toString();
      } else if (mascotaData != null) {
        _mascotaSeleccionadaId = mascotaData.toString();
      }
      
      // Convertir fechaAplicacion de UTC a hora local
      final fechaAplicacionUTC = DateTime.tryParse(v['fechaAplicacion']?.toString() ?? '');
      _fechaSeleccionada = fechaAplicacionUTC?.toLocal() ?? DateTime.now();
      
      _crearRecordatorio = v['recordatorio']?['activo'] == true;
      
      // Cargar hora del recordatorio si existe
      if (_crearRecordatorio && v['recordatorio']?['fechaRecordatorio'] != null) {
        final fechaRecordatorioUTC = DateTime.tryParse(v['recordatorio']['fechaRecordatorio'].toString());
        if (fechaRecordatorioUTC != null) {
          final fechaRecordatorioLocal = fechaRecordatorioUTC.toLocal(); // Convertir de UTC a hora local
          _horaRecordatorio = TimeOfDay(hour: fechaRecordatorioLocal.hour, minute: fechaRecordatorioLocal.minute);
        }
      }
    }
    if (widget.mascotaIdFija != null && widget.mascotaIdFija!.isNotEmpty) {
      _mascotaSeleccionadaId = widget.mascotaIdFija;
    }
    // Cargar mascotas y seleccionar una por defecto si es creación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mProv = context.read<MascotasProvider>();
      if (mProv.mascotas.isEmpty) {
        mProv.cargarMascotas(forzar: true).then((_) {
          if (mounted && widget.vacuna == null && _mascotaSeleccionadaId == null && mProv.mascotas.isNotEmpty) {
            setState(() {
              _mascotaSeleccionadaId = (mProv.mascotas.first['_id'] ?? mProv.mascotas.first['id']).toString();
            });
          }
        });
      } else if (widget.vacuna == null && _mascotaSeleccionadaId == null && mProv.mascotas.isNotEmpty) {
        _mascotaSeleccionadaId = (mProv.mascotas.first['_id'] ?? mProv.mascotas.first['id']).toString();
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
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
      initialTime: _horaRecordatorio,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _greenColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (hora != null) {
      setState(() {
        _horaRecordatorio = hora;
      });
    }
  }

  Future<void> _guardarVacuna() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Evitar múltiples clicks mientras está guardando
    if (_isLoading) return;
    
    final vacProv = context.read<VacunasProvider>();
    final mascotasProv = context.read<MascotasProvider>();
    if (mascotasProv.mascotas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Primero crea una mascota.')));
      return;
    }
    if (_mascotaSeleccionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona la mascota.')));
      return;
    }
    final mascotaId = _mascotaSeleccionadaId!;

    setState(() => _isLoading = true);
    
    String? mensajeError;
    bool exitoso = false;
    
    try {
      if (widget.vacuna == null) {
        // Crear nueva vacuna
        final ok = await vacProv.crearVacuna(
          mascotaId: mascotaId,
          nombre: _nombreController.text.trim(),
          fechaAplicacion: _fechaSeleccionada,
          observaciones: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
          ubicacion: _ubicacionController.text.trim().isEmpty ? null : _ubicacionController.text.trim(),
          recordatorio: _crearRecordatorio,
          horaRecordatorio: _crearRecordatorio ? _horaRecordatorio : null,
        );
        
        if (ok) {
          exitoso = true;
        } else {
          mensajeError = vacProv.error ?? 'Error al guardar la vacuna';
        }
      } else {
        // Editar vacuna existente
        final id = widget.vacuna!['_id'] ?? widget.vacuna!['id'];
        
        if (id == null) {
          mensajeError = 'ID de vacuna no válido';
        } else {
          final ok = await vacProv.actualizarVacuna(id.toString(), {
            'mascotaId': mascotaId,
            'nombre': _nombreController.text.trim(),
            'fechaAplicacion': _fechaSeleccionada,
            'observaciones': _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
            'ubicacion': _ubicacionController.text.trim().isEmpty ? null : _ubicacionController.text.trim(),
            'recordatorio': _crearRecordatorio,
            'horaRecordatorio': _crearRecordatorio ? _horaRecordatorio : null,
          });
          
          if (ok) {
            exitoso = true;
          } else {
            mensajeError = vacProv.error ?? 'Error al actualizar la vacuna';
          }
        }
      }
    } catch (e) {
      mensajeError = 'Error inesperado: $e';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    // Mostrar resultado
    if (!mounted) return;
    
    if (exitoso) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.vacuna == null ? 'Vacuna guardada exitosamente' : 'Vacuna actualizada exitosamente'),
        backgroundColor: _greenColor,
      ));
    } else if (mensajeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(mensajeError),
        backgroundColor: Colors.red,
      ));
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
              'Fecha de aplicación de la vacuna',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          InkWell(
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
                      DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esEdicion = widget.vacuna != null;
    
    return Scaffold(
      backgroundColor: _greenColor,
      appBar: AppBar(
        backgroundColor: _greenColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              esEdicion ? 'Editar vacuna' : 'Detalles de la vacuna',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              esEdicion ? Icons.edit : Icons.check_circle,
              color: Colors.black,
              size: 20,
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del perro
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Image.asset(
                    'assets/images/perro_vacuna_2.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 60,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Campo: ¿Cuál es la vacuna?
              // Selector de Mascota (solo creación)
              _buildSelectorMascota(context),

              _buildTextField(
                controller: _nombreController,
                label: '¿Cuál es la vacuna?',
                hint: 'Nombre de la vacuna',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el nombre de la vacuna';
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
                label: 'Agrega una descripción',
                hint: 'Descripción de la vacuna',
                maxLines: 3,
              ),
              
              const SizedBox(height: 8),
              
              // Campo: Ubicación
              _buildTextField(
                controller: _ubicacionController,
                label: '¿Dónde va a ser?',
                hint: 'Lugar de aplicación',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el lugar de aplicación';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Checkbox: Crear recordatorio
              Row(
                children: [
                  Checkbox(
                    value: _crearRecordatorio,
                    onChanged: (value) {
                      setState(() {
                        _crearRecordatorio = value ?? false;
                      });
                    },
                    activeColor: Colors.white,
                    checkColor: _greenColor,
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                  const Expanded(
                    child: Text(
                      'Crear recordatorio',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Selector de hora (solo visible si recordatorio está activado)
              if (_crearRecordatorio) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _seleccionarHora,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hora del recordatorio',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _horaRecordatorio.format(context),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.access_time, color: _greenColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Botón Guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarVacuna,
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
                          widget.vacuna != null ? 'Actualizar' : 'Guardar',
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
      
      bottomNavigationBar: const BottomNavGlobal(selectedIndex: 0),
    );
  }

  Widget _buildSelectorMascota(BuildContext context) {
    final mascotasProv = context.watch<MascotasProvider>();
    final mascotas = mascotasProv.mascotas;
    final cargando = mascotasProv.cargando && mascotas.isEmpty;
    final Map<String, Map<String, dynamic>> mascotasUnicas = {};
    for (final m in mascotas) {
      final id = (m['_id'] ?? m['id'])?.toString();
      if (id == null || id.isEmpty) continue;
      mascotasUnicas.putIfAbsent(id, () => m);
    }
    final mascotaSeleccionadaValida = (_mascotaSeleccionadaId != null &&
            mascotasUnicas.containsKey(_mascotaSeleccionadaId))
        ? _mascotaSeleccionadaId
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '¿Para qué mascota?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          if (cargando)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (mascotasUnicas.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No tienes mascotas registradas. Crea una primero.',
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            DropdownButtonFormField<String>(
              value: mascotaSeleccionadaValida,
              isExpanded: true,
              onChanged: widget.mascotaIdFija != null ? null : (val) {
                setState(() { _mascotaSeleccionadaId = val; });
              },
              validator: (val) => val == null ? 'Selecciona una mascota' : null,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: mascotasUnicas.entries.map((entry) {
                final id = entry.key;
                final nombre = (entry.value['nombre'] ?? 'Mascota').toString();
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(
                    nombre,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
// _BottomItem eliminado (se usa BottomNavGlobal)