import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/calendario_selector.dart';

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
  String _pesoPreview = '';

  @override
  void initState() {
    super.initState();

    // Robustly parse peso from registro (can be int, double, or String)
    double pesoKg = 0;
    if (widget.registro.containsKey('pesoNumerico')) {
      final dynamic pesoNum = widget.registro['pesoNumerico'];
      if (pesoNum is num) {
        pesoKg = pesoNum.toDouble();
      } else if (pesoNum is String) {
        pesoKg = double.tryParse(pesoNum) ?? 0;
      }
    } else if (widget.registro.containsKey('peso')) {
      final dynamic pesoVal = widget.registro['peso'];
      if (pesoVal is num) {
        pesoKg = pesoVal.toDouble();
      } else if (pesoVal is String) {
        pesoKg = double.tryParse(pesoVal) ?? 0;
      }
    }

    _pesoKgController = TextEditingController(text: _formatearPeso(pesoKg));
    _pesoGrController = TextEditingController(text: (pesoKg * 1000).toStringAsFixed(0));
    _notasController = TextEditingController(text: (widget.registro['notas'] ?? '').toString());
    // Parse fecha as DateTime if it's a String, otherwise use as DateTime
    final dynamic fechaRaw = widget.registro['fecha'];
    if (fechaRaw is String) {
      _fechaMedicion = DateTime.parse(fechaRaw);
      _fechaCreacion = DateTime.parse(fechaRaw);
    } else if (fechaRaw is DateTime) {
      _fechaMedicion = fechaRaw;
      _fechaCreacion = fechaRaw;
    } else {
      _fechaMedicion = DateTime.now();
      _fechaCreacion = DateTime.now();
    }

    // Inicializar preview
    _pesoPreview = 'Peso de Mascota = ${_formatearPeso(pesoKg)} kg';
  }

  // Función para parsear peso inteligentemente
  double _parseaPeso(String input) {
    if (input.isEmpty) return 0;
    
    final numero = double.tryParse(input) ?? 0;
    
    // Si el número es mayor a 100 y no tiene punto decimal
    if (numero >= 100 && !input.contains('.')) {
      // Convertir 123 -> 12.3
      return numero / 10;
    }
    
    return numero;
  }

  // Función para formatear peso para mostrar
  String _formatearPeso(double peso) {
    if (peso == 0) return '';
    
    // Si el peso es un número entero, mostrarlo sin decimales
    if (peso == peso.roundToDouble()) {
      return peso.toInt().toString();
    } else {
      // Mostrar con decimales, eliminando ceros innecesarios
      return peso.toStringAsFixed(1).replaceAll(RegExp(r'\.?0+$'), '');
    }
  }

  String _formatearFechaCompleta(DateTime fecha) {
    const meses = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    
    return '${fecha.day} de ${meses[fecha.month]}. de ${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')} PM';
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fechaSeleccionada = await mostrarCalendarioPeso(
      context: context,
      fechaInicial: _fechaMedicion,
      primeraFecha: DateTime(2020,1,1),
      ultimaFecha: DateTime.now().add(const Duration(days: 30)),
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
    final pesoKg = double.tryParse(_pesoKgController.text) ?? 0;
    
    final registroActualizado = {
      'peso': _formatearPeso(pesoKg),
      'pesoNumerico': pesoKg, // Guardamos el valor numérico exacto
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
                  const SizedBox(height: 8),
                  
                  // Preview del peso
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      _pesoPreview,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
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
                        // Aplicar lógica inteligente de parsing
                        final pesoParseado = _parseaPeso(value);
                        final gramos = pesoParseado * 1000;
                        _pesoGrController.text = gramos.toStringAsFixed(0);
                        
                        // Actualizar preview
                        setState(() {
                          _pesoPreview = 'Peso de Mascota = ${value.isEmpty ? '0' : _formatearPeso(pesoParseado)} kg';
                        });
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
                        // Aplicar lógica inteligente de parsing
                        final pesoParseado = _parseaPeso(value);
                        _pesoKgController.text = _formatearPeso(pesoParseado);
                        
                        // Actualizar preview
                        setState(() {
                          _pesoPreview = 'Peso de Mascota = ${value.isEmpty ? '0' : _formatearPeso(pesoParseado)} kg';
                        });
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