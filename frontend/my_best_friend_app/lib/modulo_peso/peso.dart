import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'lista_pesos_pantalla.dart';
import 'widgets/calendario_selector.dart';

class PesoPantalla extends StatefulWidget {
  final List<Map<String, dynamic>>? registrosExistentes;
  
  const PesoPantalla({Key? key, this.registrosExistentes}) : super(key: key);

  @override
  State<PesoPantalla> createState() => _PesoPantallaState();
}

class _PesoPantallaState extends State<PesoPantalla> {
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();
  bool _showForm = false; // Controla si mostrar el formulario o el estado vacío
  int _tabIndex = 0; // Índice para la barra de navegación inferior
  DateTime _fechaMedicionNueva = DateTime.now();
  
  // Lista de registros de peso (inicialmente vacía)
  List<Map<String, dynamic>> _registrosPeso = [];

  @override
  void initState() {
    super.initState();
    // Cargar registros existentes si se proporcionan
    if (widget.registrosExistentes != null) {
      _registrosPeso = List.from(widget.registrosExistentes!);
    }
  }

  // Función para convertir el peso ingresado
  double _parseaPeso(String input) {
    if (input.isEmpty) return 0.0;
    
    try {
      // Si contiene punto decimal, lo toma como está
      if (input.contains('.')) {
        return double.parse(input);
      } else {
        // Si no tiene punto decimal, lo convierte automáticamente
        // 123 → 12.3, 1234 → 123.4, etc.
        if (input.length <= 2) {
          // Números muy pequeños (1-99) se toman como gramos decimales
          return double.parse(input) / 10;
        } else {
          // Números de 3+ dígitos: el último dígito es decimal
          String parteEntera = input.substring(0, input.length - 1);
          String parteDecimal = input.substring(input.length - 1);
          return double.parse('$parteEntera.$parteDecimal');
        }
      }
    } catch (e) {
      return 0.0;
    }
  }

  String _formatearPeso(double peso) {
    // Formatear el peso para mostrarlo sin decimales innecesarios
    if (peso == peso.roundToDouble()) {
      return peso.toInt().toString();
    } else {
      return peso.toStringAsFixed(1);
    }
  }

  void _guardarPeso() {
    if (_pesoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el peso'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double pesoParseado = _parseaPeso(_pesoController.text);
    if (pesoParseado <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un peso válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _registrosPeso.insert(0, {
        'peso': _formatearPeso(pesoParseado),
        'pesoNumerico': pesoParseado, // Guardamos el valor numérico para cálculos
        'fecha': _fechaMedicionNueva,
        'notas': _notasController.text.isEmpty ? '' : _notasController.text,
      });
    });

    _pesoController.clear();
    _notasController.clear();

    // Navegar a la pantalla de lista de pesos
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaPesosPantalla(
          registrosPeso: _registrosPeso,
        ),
      ),
    ).then((result) {
      if (result != null && result is List<Map<String, dynamic>>) {
        setState(() {
          _registrosPeso = result;
        });
      }
    });
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar estado vacío solo si no hay registros Y no se está mostrando el formulario Y no hay registros existentes
    if (_registrosPeso.isEmpty && !_showForm && widget.registrosExistentes == null) {
      return _buildEmptyState();
    }
    
    return _buildMainView();
  }

  // Estado vacío con imagen del perro en la báscula
  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
              selected: _tabIndex == 0,
              onTap: () => setState(() => _tabIndex = 0),
            ),
            _BottomItem(
              icon: Icons.calendar_month,
              selected: _tabIndex == 1,
              onTap: () => setState(() => _tabIndex = 1),
            ),
            _BottomItem(
              icon: Icons.settings,
              selected: _tabIndex == 2,
              onTap: () => setState(() => _tabIndex = 2),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Imagen del perro en la báscula
            Container(
              width: 250,
              height: 200,
              child: Image.asset(
                'assets/images/perro_peso.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 40),
            // Mensaje
            const Text(
              '¡Agrega un peso para\ncomenzar!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            // Botón Crear
            Container(
              width: 120,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showForm = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Crear',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // Vista principal con formulario y lista
  Widget _buildMainView() {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Peso',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Botones de Kilogramo y Gramo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Lógica para kilogramo
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: const Text(
                        'Kilogramo',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Lógica para gramo
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: const Text(
                        'Gramo',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Peso de Mascota
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Peso de Mascota = ${_pesoController.text.isEmpty ? '0' : _pesoController.text} gr',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Campo de entrada para el peso
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _pesoController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Ej: 12.3',
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 16),
                          onChanged: (value) {
                            setState(() {
                              // Actualizar la UI cuando cambie el texto
                            });
                          },
                        ),
                        // Vista previa del peso interpretado
                        if (_pesoController.text.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Text(
                              'Peso interpretado: ${_formatearPeso(_parseaPeso(_pesoController.text))} kg',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sección de Notas
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Campo Agregar Nota
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _notasController,
                      decoration: const InputDecoration(
                        hintText: 'Agregar Nota',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campo Medido en
                  const Text(
                    'Medido en',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final fecha = await mostrarCalendarioPeso(
                        context: context,
                        fechaInicial: _fechaMedicionNueva,
                        primeraFecha: DateTime(2020,1,1),
                        ultimaFecha: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (fecha != null) {
                        // Opcional: pedir también hora
                        final hora = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_fechaMedicionNueva),
                        );
                        setState(() {
                          _fechaMedicionNueva = DateTime(
                            fecha.year,
                            fecha.month,
                            fecha.day,
                            hora?.hour ?? _fechaMedicionNueva.hour,
                            hora?.minute ?? _fechaMedicionNueva.minute,
                          );
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_fechaMedicionNueva.day} ${_getMonthName(_fechaMedicionNueva.month)} ${_fechaMedicionNueva.year} ${_fechaMedicionNueva.hour.toString().padLeft(2, '0')}:${_fechaMedicionNueva.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botón Guardar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _guardarPeso,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
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
            ),
          ],
        ),
      ),
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
              selected: _tabIndex == 0,
              onTap: () => setState(() => _tabIndex = 0),
            ),
            _BottomItem(
              icon: Icons.calendar_month,
              selected: _tabIndex == 1,
              onTap: () => setState(() => _tabIndex = 1),
            ),
            _BottomItem(
              icon: Icons.settings,
              selected: _tabIndex == 2,
              onTap: () => setState(() => _tabIndex = 2),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _notasController.dispose();
    super.dispose();
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