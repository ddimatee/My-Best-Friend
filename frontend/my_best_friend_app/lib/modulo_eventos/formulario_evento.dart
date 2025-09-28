import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'modelos/evento.dart';
import 'servicios/evento_service.dart';
import '../modulo_peso/widgets/calendario_selector.dart';
import 'seleccion_categoria_evento.dart';

class FormularioEvento extends StatefulWidget {
  final String categoria;
  final Evento? evento; // Para editar un evento existente

  const FormularioEvento({Key? key, required this.categoria, this.evento}) : super(key: key);

  @override
  State<FormularioEvento> createState() => _FormularioEventoState();
}

class _FormularioEventoState extends State<FormularioEvento> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  DateTime _fechaSeleccionada = DateTime.now();
  bool _crearRecordatorio = false;
  bool _isLoading = false;
  String _categoriaSeleccionada = '';
  final Color _greenColor = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _categoriaSeleccionada = widget.categoria;
    if (widget.evento != null) {
      _tituloController.text = widget.evento!.titulo;
      _descripcionController.text = widget.evento!.descripcion;
      _fechaSeleccionada = widget.evento!.fecha;
      _crearRecordatorio = widget.evento!.tieneRecordatorio;
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

  Future<void> _cambiarCategoria() async {
    final String? nuevaCategoria = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const SeleccionCategoriaEvento(),
      ),
    );

    if (nuevaCategoria != null) {
      setState(() {
        _categoriaSeleccionada = nuevaCategoria;
      });
    }
  }

  Future<void> _guardarEvento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final evento = Evento(
        id: widget.evento?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: _tituloController.text.trim(),
        categoria: _categoriaSeleccionada,
        fecha: _fechaSeleccionada,
        descripcion: _descripcionController.text.trim(),
        tieneRecordatorio: _crearRecordatorio,
      );

      bool success;
      if (widget.evento != null) {
        success = await EventoService.actualizarEvento(evento);
      } else {
        success = await EventoService.guardarEvento(evento);
      }

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.evento != null 
                  ? 'Evento actualizado exitosamente'
                  : 'Evento guardado exitosamente',
            ),
            backgroundColor: _greenColor,
          ),
        );
      } else {
        throw Exception('Error al guardar');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el evento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
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
                      DateFormat('d \'de\' MMM, yyyy - h:mm a').format(_fechaSeleccionada),
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
                onTap: _cambiarCategoria,
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
                        _getIconoCategoria(_categoriaSeleccionada),
                        color: _greenColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Categoría: $_categoriaSeleccionada',
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

  IconData _getIconoCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'paseo':
        return Icons.directions_walk;
      case 'juego':
        return Icons.sports_basketball;
      case 'comida':
        return Icons.restaurant;
      case 'baño':
        return Icons.bathtub;
      case 'veterinario':
        return Icons.local_hospital;
      case 'entrenamiento':
        return Icons.school;
      case 'socialización':
        return Icons.group;
      case 'descanso':
        return Icons.bed;
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