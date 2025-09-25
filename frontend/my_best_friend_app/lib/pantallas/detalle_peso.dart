import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetallePesoPantalla extends StatefulWidget {
  final Map<String, dynamic> registro;
  final Function(Map<String, dynamic>) onActualizar;

  const DetallePesoPantalla({
    Key? key,
    required this.registro,
    required this.onActualizar,
  }) : super(key: key);

  @override
  State<DetallePesoPantalla> createState() => _DetallePesoPantallaState();
}

class _DetallePesoPantallaState extends State<DetallePesoPantalla> {
  late TextEditingController _pesoKgController;
  late TextEditingController _pesoGrController;
  late TextEditingController _notasController;
  late DateTime _fechaMedicion;
  late DateTime _fechaCreacion;

  @override
  void initState() {
    super.initState();
    
    final pesoGramos = double.tryParse(widget.registro['peso']) ?? 0;
    final pesoKg = pesoGramos / 1000;
    
    _pesoKgController = TextEditingController(text: pesoKg.toStringAsFixed(3));
    _pesoGrController = TextEditingController(text: pesoGramos.toStringAsFixed(0));
    _notasController = TextEditingController(text: widget.registro['notas'] ?? '');
    _fechaMedicion = widget.registro['fecha'] as DateTime;
    _fechaCreacion = widget.registro['fecha'] as DateTime;
  }

  String _formatearFechaCompleta(DateTime fecha) {
    const meses = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    
    return '${fecha.day} de ${meses[fecha.month]}. de ${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')} PM';
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaMedicion,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF4CAF50),
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      final TimeOfDay? horaSeleccionada = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_fechaMedicion),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: const Color(0xFF4CAF50),
              ),
            ),
            child: child!,
          );
        },
      );

      if (horaSeleccionada != null) {
        setState(() {
          _fechaMedicion = DateTime(
            fechaSeleccionada.year,
            fechaSeleccionada.month,
            fechaSeleccionada.day,
            horaSeleccionada.hour,
            horaSeleccionada.minute,
          );
        });
      }
    }
  }

  void _actualizarPeso() {
    final pesoGramos = double.tryParse(_pesoGrController.text) ?? 0;
    
    final registroActualizado = {
      'peso': pesoGramos.toString(),
      'fecha': _fechaMedicion,
      'notas': _notasController.text,
    };

    widget.onActualizar(registroActualizado);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Peso actualizado exitosamente'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Título
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: const Text(
                'Peso de Mascota',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // Formulario
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Detalles
                  const Text(
                    'Detalles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo Peso en kg
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _pesoKgController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      ],
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                        suffixText: 'kg',
                      ),
                      style: const TextStyle(fontSize: 16),
                      onChanged: (value) {
                        final kg = double.tryParse(value) ?? 0;
                        final gramos = kg * 1000;
                        _pesoGrController.text = gramos.toStringAsFixed(0);
                        setState(() {});
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campo Cambio
                  const Text(
                    'Cambio',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _pesoGrController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      ],
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                        suffixText: 'kg',
                      ),
                      style: const TextStyle(fontSize: 16),
                      onChanged: (value) {
                        final gramos = double.tryParse(value) ?? 0;
                        final kg = gramos / 1000;
                        _pesoKgController.text = kg.toStringAsFixed(3);
                        setState(() {});
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Notas
                  const Text(
                    'Notas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _notasController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Nota',
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Fechas
                  const Text(
                    'Fechas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Medido en
                  const Text(
                    'Medido en',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _seleccionarFecha,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        _formatearFechaCompleta(_fechaMedicion),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Creado el
                  const Text(
                    'Creado el',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      _formatearFechaCompleta(_fechaCreacion),
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botón Actualizar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _actualizarPeso,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Actualizar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pesoKgController.dispose();
    _pesoGrController.dispose();
    _notasController.dispose();
    super.dispose();
  }
}