import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'lista_pesos_pantalla.dart'; // legacy navegación lista local
import 'widgets/calendario_selector.dart';
import 'lista_pesos_pantalla.dart';
import 'package:provider/provider.dart';
import '../../providers/peso_provider.dart';
import '../../providers/mascotas_provider.dart';
import 'widgets/registro_peso_detalle.dart';
import '../modulo_general/widgets/bottom_nav_global.dart';

class PesoPantalla extends StatefulWidget {
  final List<Map<String, dynamic>>? registrosExistentes; // legacy param (ya no se usa con provider)
  final String? mascotaId;
  const PesoPantalla({Key? key, this.registrosExistentes, this.mascotaId}) : super(key: key);

  @override
  State<PesoPantalla> createState() => _PesoPantallaState();
}

class _PesoPantallaState extends State<PesoPantalla> {
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();
  bool _showForm = false; // Controla si mostrar el formulario o el estado vacío
  DateTime _fechaMedicionNueva = DateTime.now();
  
  // Lista de registros de peso (inicialmente vacía)
  List<Map<String, dynamic>> _registrosPeso = [];
  bool _guardando = false;
  String? _mascotaSeleccionada; // id de la mascota elegida
  bool _cargandoPesosMascota = false; // indica si se está cargando el cambio de mascota

  @override
  void initState() {
    super.initState();
    // Cargar registros existentes si se proporcionan
    if (widget.registrosExistentes != null) {
      _registrosPeso = List.from(widget.registrosExistentes!); // soporte transitorio
    }
    // Mascota inicial si viene por parámetro
    _mascotaSeleccionada = widget.mascotaId;
    // Intentar cargar mascotas si no hay
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mascProv = context.read<MascotasProvider>();
      if (mascProv.mascotas.isEmpty) {
        await mascProv.cargarMascotas();
      }
      if (_mascotaSeleccionada == null && mascProv.mascotas.isNotEmpty) {
        setState(() {
          _mascotaSeleccionada = (mascProv.mascotas.first['_id'] ?? mascProv.mascotas.first['id']).toString();
        });
        await _cargarRegistrosDeMascota();
      }
    });
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

  void _guardarPeso() async {
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

    final mascotaId = _mascotaSeleccionada ?? widget.mascotaId;
    if (mascotaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se ha seleccionado mascota'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() { _guardando = true; });
    try {
      final pesoProv = Provider.of<PesoProvider>(context, listen: false);
      final ok = await pesoProv.crear(
        mascotaId: mascotaId,
        peso: pesoParseado,
        fecha: _fechaMedicionNueva,
        observaciones: _notasController.text.isEmpty ? null : _notasController.text,
      );
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(pesoProv.error ?? 'Error al guardar'), backgroundColor: Colors.red),
        );
        return;
      }
      if (!mounted) return;
      // Obtener el último registro insertado para navegar a detalle
      final ultimo = pesoProv.registros(mascotaId).isNotEmpty ? pesoProv.registros(mascotaId).first : null;
      if (!mounted) return;
      if (ultimo != null) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RegistroPesoDetallePantalla(registro: ultimo, mascotaId: mascotaId),
          ),
        );
      } else {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() { _guardando = false; });
    }
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
      bottomNavigationBar: const BottomNavGlobal(selectedIndex: 0),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.white),
            tooltip: 'Ver historial completo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListaPesosPantalla(mascotaId: _mascotaSeleccionada),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSelectorMascota(),
            const SizedBox(height: 16),
            // (Se removió el selector de unidad Kilogramo/Gramo a petición del usuario)
            const SizedBox(height: 8),
            _buildHistorial(),

            // Botón para ir a la lista avanzada
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Ver historial completo'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListaPesosPantalla(mascotaId: _mascotaSeleccionada),
                    ),
                  );
                },
              ),
            ),

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
                      onPressed: _guardando ? null : _guardarPeso,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _guardando
                          ? const SizedBox(height:20, width:20, child: CircularProgressIndicator(strokeWidth:2, color: Colors.white))
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavGlobal(selectedIndex: 0),
    );
  }

  Widget _buildHistorial() {
    if (_mascotaSeleccionada == null) return const SizedBox.shrink();
    final pesoProv = context.watch<PesoProvider>();
    final registros = pesoProv.registros(_mascotaSeleccionada!);
    if (registros.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Historial reciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...registros.take(5).map((r) {
            final fechaStr = _formatFecha(r['fecha'] ?? r['createdAt']);
            final peso = r['peso']?.toString() ?? '-';
            return ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text('$peso kg', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(fechaStr),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegistroPesoDetallePantalla(registro: r, mascotaId: _mascotaSeleccionada!),
                  ),
                );
              },
            );
          }).toList(),
          if (registros.length > 5)
            TextButton(
              onPressed: () {
                _mostrarHistorialCompleto(registros);
              },
              child: const Text('Ver todos'),
            )
        ],
      ),
    );
  }

  void _mostrarHistorialCompleto(List<Map<String,dynamic>> registros) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (_, scroll) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Historial completo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scroll,
                      itemCount: registros.length,
                      itemBuilder: (c, i) {
                        final r = registros[i];
                        final fechaStr = _formatFecha(r['fecha'] ?? r['createdAt']);
                        final peso = r['peso']?.toString() ?? '-';
                        return ListTile(
                          title: Text('$peso kg'),
                          subtitle: Text(fechaStr),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegistroPesoDetallePantalla(registro: r, mascotaId: _mascotaSeleccionada!),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      }
    );
  }

  String _formatFecha(dynamic raw) {
    DateTime? f;
    if (raw is DateTime) {
      f = raw;
    } else if (raw is String) {
      f = DateTime.tryParse(raw);
    }
    f ??= DateTime.now();
    return '${f.day.toString().padLeft(2,'0')}/${f.month.toString().padLeft(2,'0')}/${f.year} ${f.hour.toString().padLeft(2,'0')}:${f.minute.toString().padLeft(2,'0')}';
  }

  Widget _buildSelectorMascota() {
    final mascProv = context.watch<MascotasProvider>();
    final mascotas = mascProv.mascotas;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pets, color: Colors.black54),
              const SizedBox(width: 8),
              const Text('Mascota', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                tooltip: 'Refrescar',
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: mascProv.cargando ? null : () async {
                  await mascProv.cargarMascotas(forzar: true);
                  // Imprimir lista para depuración
                  for (final m in mascProv.mascotas) {
                    // ignore: avoid_print
                    print('🐕 Mascota cargada: id=' + (m['_id']?.toString() ?? m['id']?.toString() ?? '??') + ' nombre=' + (m['nombre']?.toString() ?? '')); 
                  }
                  setState(() {});
                },
              ),
              if (mascProv.cargando)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth:2)),
            ],
          ),
          const SizedBox(height: 12),
          if (mascotas.isEmpty && !mascProv.cargando)
            const Text('No tienes mascotas aún. Crea una primero.', style: TextStyle(color: Colors.redAccent))
          else
            DropdownButtonFormField<String>(
              value: _mascotaSeleccionada,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              hint: const Text('Selecciona una mascota'),
              items: mascotas.map((m) {
                final id = (m['_id'] ?? m['id']).toString();
                final nombre = m['nombre']?.toString() ?? 'Sin nombre';
                // Log puntual para revisar si aún existe 'jose'
                if (nombre.toLowerCase() == 'jose') {
                  // ignore: avoid_print
                  print('⚠️  Aún presente nombre "jose" en dropdown con id=$id');
                }
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(nombre),
                );
              }).toList(),
              onChanged: (val) async {
                if (val == null || val == _mascotaSeleccionada) return;
                setState(() { _mascotaSeleccionada = val; _cargandoPesosMascota = true; });
                await _cargarRegistrosDeMascota();
                if (mounted) setState(() { _cargandoPesosMascota = false; });
              },
            ),
          const SizedBox(height: 4),
          if (_mascotaSeleccionada == null)
            const Text('Debes seleccionar una mascota para guardar el peso', style: TextStyle(fontSize: 12, color: Colors.orange)),
          if (_cargandoPesosMascota)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(minHeight: 4),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _cargarRegistrosDeMascota() async {
    final mascotaId = _mascotaSeleccionada;
    if (mascotaId == null) return;
    final pesoProv = context.read<PesoProvider>();
    await pesoProv.cargar(mascotaId: mascotaId, forzar: true);
    // Sincronizar lista local para que la lógica de estado vacío funcione correctamente
    final registros = pesoProv.registros(mascotaId);
    setState(() {
      _registrosPeso = List.from(registros);
      if (_registrosPeso.isNotEmpty) {
        // Si había estado vacío y ahora hay registros, aseguramos mostrar vista principal
        _showForm = _showForm; // no cambiar si usuario abrió el formulario
      }
    });
  }
}

// _BottomItem eliminado en favor de BottomNavGlobal