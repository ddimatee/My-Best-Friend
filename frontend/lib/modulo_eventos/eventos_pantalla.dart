import 'dart:async';
import 'package:flutter/material.dart';
import '../modulo_general/widgets/bottom_nav_global.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_date_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/eventos_provider.dart';
import '../../providers/mascotas_provider.dart';
import 'seleccion_categoria_evento.dart';
import 'detalle_evento.dart';
import 'formulario_evento.dart';

class EventosPantalla extends StatefulWidget {
  const EventosPantalla({Key? key}) : super(key: key);

  @override
  State<EventosPantalla> createState() => _EventosPantallaState();
}

class _EventosPantallaState extends State<EventosPantalla> {
  List<Map<String, dynamic>> _eventos = [];
  bool _isLoading = true;
  final Color _greenColor = const Color(0xFF4CAF50);
  String? _mascotaSeleccionada;
  DateTime _fechaActual = DateTime.now();
  bool _mostrarTodos = true; // nuevo: mostrar todos los eventos
  bool _cargandoMascotas = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('=== INICIO carga eventos pantalla ===');
      try {
        final masc = context.read<MascotasProvider>();
        print('Mascotas actuales: ${masc.mascotas.length}');
        
        if (masc.mascotas.isEmpty) {
          print('Cargando mascotas desde API...');
          setState(() => _cargandoMascotas = true);
          await masc.cargarMascotas().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('TIMEOUT al cargar mascotas');
              throw TimeoutException('Tiempo de espera agotado al cargar mascotas');
            },
          );
          if (mounted) setState(() => _cargandoMascotas = false);
          print('Mascotas cargadas: ${masc.mascotas.length}');
        }
        
        if (masc.mascotas.isNotEmpty) {
          _mascotaSeleccionada = (masc.mascotas.first['_id'] ?? masc.mascotas.first['id']).toString();
          print('Mascota seleccionada: $_mascotaSeleccionada');
          print('Cargando eventos (todos) ...');
          await _cargarEventos();
          print('Eventos cargados: ${_eventos.length}');
        } else {
          print('No hay mascotas para mostrar');
          setState(() { _isLoading = false; });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No hay mascotas registradas')),
            );
          }
        }
        print('=== FIN carga eventos pantalla ===');
      } catch (e) {
        print('❌ ERROR en initState de eventos: $e');
        if (mounted) {
          setState(() { _isLoading = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar: $e')),
          );
        }
      }
    });
  }

  Future<void> _cargarEventos() async {
    if (_mascotaSeleccionada == null) {
      print('⚠️ No hay mascota seleccionada');
      setState(() { _isLoading = false; });
      return;
    }
    print('>>> Cargando ${_mostrarTodos ? 'TODOS los eventos' : 'eventos del día'} para mascota: $_mascotaSeleccionada');
    setState(() { _isLoading = true; });
    try {
      final prov = context.read<EventosProvider>();
      if (_mostrarTodos) {
        await prov.cargarTodos(mascotaId: _mascotaSeleccionada, forzar: true);
        final lista = prov.todosEventos;
        print('Total eventos cargados (todos): ${lista.length}');
        setState(() {
          _eventos = lista;
          _isLoading = false;
        });
      } else {
        await prov.cargarDia(_fechaActual, mascotaId: _mascotaSeleccionada, forzar: true);
        final key = _key(_fechaActual);
        final lista = prov.eventosDeDia(key);
        print('Eventos del día $key: ${lista.length}');
        setState(() {
          _eventos = lista;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ ERROR al cargar eventos: $e');
      if (mounted) {
        setState(() { _isLoading = false; _eventos = []; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar eventos: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _key(DateTime d) => '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  void _navegarASeleccionTipo() async {
    final String? tipo = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const SeleccionCategoriaEvento(),
      ),
    );

    if (tipo != null) {
      // Navegar al formulario de evento con la categoría seleccionada
      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormularioEvento(tipoInicial: tipo, mascotaId: _mascotaSeleccionada),
        ),
      );
      
      if (resultado == true) {
        _cargarEventos();
      }
    }
  }

  void _navegarADetalle(Map<String,dynamic> evento) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleEvento(evento: evento),
      ),
    );

    if (resultado == true) {
      _cargarEventos();
    }
  }

  Widget _buildEventoCard(Map<String,dynamic> evento) {
    final fecha = DateTime.tryParse(evento['fecha']?.toString() ?? '') ?? DateTime.now();
  final tipo = (evento['tipo'] ?? evento['categoria'] ?? 'evento').toString();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navegarADetalle(evento),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                _getIconoCategoria(tipo),
                color: _greenColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (evento['titulo'] ?? '').toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'De: ${DateFormat('d MMM, yyyy').format(fecha)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _horaDesde(fecha, evento),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.edit,
              color: Colors.black54,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorMascota() {
    final mascProv = context.watch<MascotasProvider>();
    final lista = mascProv.mascotas;
    if (_cargandoMascotas) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: LinearProgressIndicator(minHeight: 6, backgroundColor: Colors.white54),
      );
    }
    if (lista.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'No hay mascotas. Crea una para comenzar a registrar eventos.',
          style: TextStyle(color: Colors.black87),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0,2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.pets, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _mascotaSeleccionada,
                isExpanded: true,
                icon: const Icon(Icons.expand_more),
                items: lista.map((m) {
                  final id = (m['_id'] ?? m['id']).toString();
                  final nombre = (m['nombre'] ?? 'Mascota').toString();
                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() { _mascotaSeleccionada = val; });
                  _cargarEventos();
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _greenColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _mostrarTodos ? 'Todos' : DateFormat('dd/MM').format(_fechaActual),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(
                  255,
                  (_greenColor.red * 0.8).round(),
                  (_greenColor.green * 0.8).round(),
                  (_greenColor.blue * 0.8).round(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _horaDesde(DateTime fecha, Map<String,dynamic> evento) {
    if (evento['hora'] != null) return evento['hora'];
    return DateFormat('h:mm a').format(fecha);
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          // Contenido principal con texto y botón
          Positioned(
            left: 0,
            right: 0,
            top: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'No se ha encontrado ningún\nevento, ¡créalo!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _navegarASeleccionTipo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Crear',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            top: 200, 
            child: Container(
              width: 280,
              height: 200,
              child: Image.asset(
                'assets/images/perro_evento.png',
                width: 280,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('Error cargando imagen perro_evento.png: $error');
                  return Container(
                    width: 280,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _greenColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(
                      Icons.pets,
                      size: 60,
                      color: _greenColor,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  final fechaFormateada = DateFormat('d \'de\' MMM, yyyy', 'es').format(_fechaActual);
    
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
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_mostrarTodos)
              GestureDetector(
                onTap: () async {
                  final nuevaFecha = await CustomDatePicker.show(
                    context,
                    initialDate: _fechaActual,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    primaryColor: _greenColor,
                  );
                  if (nuevaFecha != null && nuevaFecha != _fechaActual) {
                    setState(() { _fechaActual = nuevaFecha; });
                    _cargarEventos();
                  }
                },
                child: Row(children: [
                  Text(
                    fechaFormateada,
                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.calendar_today, color: Colors.black, size: 18),
                ]),
              )
            else
              const Text('Todos los eventos', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _mostrarTodos ? 'Ver por día' : 'Ver todos',
            onPressed: () {
              setState(() { _mostrarTodos = !_mostrarTodos; });
              _cargarEventos();
            },
            icon: Icon(_mostrarTodos ? Icons.calendar_today : Icons.view_list, color: Colors.black),
          ),
          if (_eventos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: _navegarASeleccionTipo,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : _eventos.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 90),
                  itemCount: _eventos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildSelectorMascota();
                    final ev = _eventos[index - 1];
                    return _buildEventoCard(ev);
                  },
                ),
      bottomNavigationBar: const BottomNavGlobal(selectedIndex: 0),
      floatingActionButton: (_mascotaSeleccionada == null)
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _navegarASeleccionTipo,
              child: const Icon(Icons.add, color: Colors.black),
            ),
    );
  }
}
// _BottomItem eliminado (se usa BottomNavGlobal)