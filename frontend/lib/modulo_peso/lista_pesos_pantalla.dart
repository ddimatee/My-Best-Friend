import 'package:flutter/material.dart';
import '../modulo_general/widgets/bottom_nav_global.dart';
import 'detalle_peso.dart';
import 'peso.dart';
import 'package:provider/provider.dart';
import '../../providers/peso_provider.dart';
import '../../providers/mascotas_provider.dart';

class ListaPesosPantalla extends StatefulWidget {
  final String? mascotaId; // si se desea filtrar por mascota específica
  const ListaPesosPantalla({Key? key, this.mascotaId}) : super(key: key);

  @override
  State<ListaPesosPantalla> createState() => _ListaPesosPantallaState();
}

class _ListaPesosPantallaState extends State<ListaPesosPantalla> {
  List<Map<String, dynamic>> _registrosPeso = [];
  List<Map<String, dynamic>> _registrosFiltrados = [];
  String _filtroSeleccionado = 'Hoy';
  String? _mascotaSeleccionada;
  bool _cargandoInicial = true;
  late final ScrollController _scrollController;
  VoidCallback? _pesoListener;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mascProv = context.read<MascotasProvider>();
      final pesoProv = context.read<PesoProvider>();
      if (mascProv.mascotas.isEmpty) {
        await mascProv.cargarMascotas();
      }
      if (widget.mascotaId != null) {
        _mascotaSeleccionada = widget.mascotaId;
      } else if (mascProv.mascotas.isNotEmpty) {
        _mascotaSeleccionada = (mascProv.mascotas.first['_id'] ?? mascProv.mascotas.first['id']).toString();
      }
      if (_mascotaSeleccionada != null) {
        await pesoProv.cargar(mascotaId: _mascotaSeleccionada);
        _refrescarDesdeProvider();
        // Escuchar cambios futuros (creación/actualización/eliminación)
        _pesoListener = () {
          if (!mounted) return;
            _refrescarDesdeProvider(autoScrollTop: true);
        };
        pesoProv.addListener(_pesoListener!);
      }
      setState(() { _cargandoInicial = false; });
    });
  }

  @override
  void dispose() {
    if (_pesoListener != null) {
      context.read<PesoProvider>().removeListener(_pesoListener!);
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _refrescarDesdeProvider({bool autoScrollTop = false}) {
    final pesoProv = context.read<PesoProvider>();
    if (_mascotaSeleccionada != null) {
      _registrosPeso = List.from(pesoProv.registros(_mascotaSeleccionada!));
      _aplicarFiltro();
      if (autoScrollTop && _scrollController.hasClients) {
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    }
  }


  String _formatearFecha(DateTime fecha) {
    const meses = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    return '${fecha.day} ${meses[fecha.month]} ${fecha.year} - ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  void _aplicarFiltro() {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    DateTime? _parseFecha(dynamic raw) {
      if (raw is DateTime) return raw;
      if (raw is String) return DateTime.tryParse(raw);
      return null;
    }
    setState(() {
      switch (_filtroSeleccionado) {
        case 'Hoy':
          _registrosFiltrados = _registrosPeso.where((registro) {
            final fechaRegistro = _parseFecha(registro['fecha']);
            if (fechaRegistro == null) return false;
            // Convertir a local si viene en UTC
            final local = fechaRegistro.toLocal();
            final diaRegistro = DateTime(local.year, local.month, local.day);
            return diaRegistro.isAtSameMomentAs(hoy);
          }).toList();
          break;
        case '1 sem.':
          final unaSemanaAtras = hoy.subtract(const Duration(days: 7));
          _registrosFiltrados = _registrosPeso.where((registro) {
            final fechaRegistro = _parseFecha(registro['fecha']);
            if (fechaRegistro == null) return false;
            final local = fechaRegistro.toLocal();
            return local.isAfter(unaSemanaAtras) && local.isBefore(ahora.add(const Duration(days: 1)));
          }).toList();
          break;
        case '1 mes':
          final unMesAtras = DateTime(ahora.year, ahora.month - 1, ahora.day);
          _registrosFiltrados = _registrosPeso.where((registro) {
            final fechaRegistro = _parseFecha(registro['fecha']);
            if (fechaRegistro == null) return false;
            final local = fechaRegistro.toLocal();
            return local.isAfter(unMesAtras) && local.isBefore(ahora.add(const Duration(days: 1)));
          }).toList();
          break;
        case '1 año':
          final unAnoAtras = DateTime(ahora.year - 1, ahora.month, ahora.day);
          _registrosFiltrados = _registrosPeso.where((registro) {
            final fechaRegistro = _parseFecha(registro['fecha']);
            if (fechaRegistro == null) return false;
            final local = fechaRegistro.toLocal();
            return local.isAfter(unAnoAtras) && local.isBefore(ahora.add(const Duration(days: 1)));
          }).toList();
          break;
        case 'Personalizado':
          _registrosFiltrados = List.from(_registrosPeso);
          break;
        default:
          _registrosFiltrados = List.from(_registrosPeso);
      }
    });
  }

  void _seleccionarFiltro(String filtro) {
    if (filtro == 'Personalizado') {
      _mostrarSelectorFechaPersonalizado();
    } else {
      setState(() {
        _filtroSeleccionado = filtro;
      });
      _aplicarFiltro();
    }
  }

  void _mostrarSelectorFechaPersonalizado() async {
    final DateTimeRange? rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      locale: const Locale('es', 'ES'),
    );
    
    if (rango != null) {
      setState(() {
        _filtroSeleccionado = 'Personalizado';
        _registrosFiltrados = _registrosPeso.where((registro) {
          DateTime? fechaRegistro;
          final raw = registro['fecha'];
          if (raw is DateTime) {
            fechaRegistro = raw;
          } else if (raw is String) {
            fechaRegistro = DateTime.tryParse(raw);
          }
          if (fechaRegistro == null) return false;
          return fechaRegistro.isAfter(rango.start.subtract(const Duration(days: 1))) &&
                 fechaRegistro.isBefore(rango.end.add(const Duration(days: 1)));
        }).toList();
      });
    }
  }

  String _formatearPesoParaLista(double peso) {
    // Formatear peso como en el mockup: "00.000" format
    return peso.toStringAsFixed(3).padLeft(6, '0');
  }

  void _eliminarRegistro(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar registro'),
          content: const Text('¿Estás seguro de que quieres eliminar este registro de peso?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final registroAEliminar = _registrosFiltrados[index];
                final id = registroAEliminar['_id'] ?? registroAEliminar['id'];
                context.read<PesoProvider>().eliminar(id).then((ok) {
                  if (ok) {
                    _refrescarDesdeProvider();
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registro eliminado'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _agregarNuevoPeso() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PesoPantalla(mascotaId: _mascotaSeleccionada),
      ),
    ).then((_) => _refrescarDesdeProvider());
  }

  Widget _buildSelectorMascota() {
    final mascProv = context.watch<MascotasProvider>();
    final mascotas = mascProv.mascotas;
    if (mascotas.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      alignment: Alignment.centerLeft,
      child: DropdownButtonHideUnderline(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButton<String>(
            value: _mascotaSeleccionada,
            dropdownColor: const Color(0xFF4CAF50),
            iconEnabledColor: Colors.white,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: mascotas.map<DropdownMenuItem<String>>((m) {
              final id = (m['_id'] ?? m['id']).toString();
              final nombre = m['nombre']?.toString() ?? 'Mascota';
              return DropdownMenuItem<String>(
                value: id,
                child: Text(nombre, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (nuevo) async {
              if (nuevo == null) return;
              setState(() { _mascotaSeleccionada = nuevo; _cargandoInicial = true; });
              final pesoProv = context.read<PesoProvider>();
              await pesoProv.cargar(mascotaId: nuevo);
              _refrescarDesdeProvider(autoScrollTop: true);
              setState(() { _cargandoInicial = false; });
            },
          ),
        ),
      ),
    );
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
          onPressed: () {
            // Regresar al menú principal
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              onPressed: _agregarNuevoPeso,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de mascota
          _buildSelectorMascota(),
          // Filtros
          Container(
            color: const Color(0xFF4CAF50),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _FilterChip(
                      label: 'Hoy',
                      selected: _filtroSeleccionado == 'Hoy',
                      onTap: () => _seleccionarFiltro('Hoy'),
                    ),
                    _FilterChip(
                      label: '1 sem.',
                      selected: _filtroSeleccionado == '1 sem.',
                      onTap: () => _seleccionarFiltro('1 sem.'),
                    ),
                    _FilterChip(
                      label: '1 mes',
                      selected: _filtroSeleccionado == '1 mes',
                      onTap: () => _seleccionarFiltro('1 mes'),
                    ),
                    _FilterChip(
                      label: '1 año',
                      selected: _filtroSeleccionado == '1 año',
                      onTap: () => _seleccionarFiltro('1 año'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FilterChip(
                  label: 'Personalizado',
                  selected: _filtroSeleccionado == 'Personalizado',
                  onTap: () => _seleccionarFiltro('Personalizado'),
                ),
              ],
            ),
          ),
          
          if (_cargandoInicial)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.white)))
          else
          // Lista de registros
          Expanded(
            child: Container(
              color: const Color(0xFF4CAF50),
              child: _registrosFiltrados.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _registrosPeso.isEmpty 
                                ? 'No hay registros de peso'
                                : 'No hay registros en este período',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _registrosFiltrados.length,
                      itemBuilder: (context, index) {
                        final registro = _registrosFiltrados[index];
            final fechaRaw = registro['fecha'];
            final fecha = (fechaRaw is DateTime)
              ? fechaRaw
              : (fechaRaw is String ? DateTime.tryParse(fechaRaw) ?? DateTime.now() : DateTime.now());
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Ícono de mascota
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.pets,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              ),
                              
                              const SizedBox(width: 12),
                              
                              // Información del peso
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_formatearPesoParaLista(_parsePeso(registro))} kg',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatearFecha(fecha),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    // Mostrar notas u observaciones si existen
                                    if ((registro['notas'] != null && registro['notas'].toString().isNotEmpty) ||
                                        (registro['observaciones'] != null && registro['observaciones'].toString().isNotEmpty)) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        registro['notas']?.toString() ?? registro['observaciones']?.toString() ?? '',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade700,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              
                              // Botón de editar
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.grey),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetallePesoPantalla(
                                        registro: registro,
                                        onActualizar: (regAct) async {
                                          final id = registro['_id'] ?? registro['id'];
                                          final cambios = {
                                            'peso': _parsePeso(regAct),
                                            'fecha': regAct['fecha'],
                                            'observaciones': regAct['notas'],
                                          };
                                          await context.read<PesoProvider>().actualizar(id, cambios);
                                          _refrescarDesdeProvider();
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              // Botón de eliminar
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.grey),
                                onPressed: () => _eliminarRegistro(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      
      bottomNavigationBar: const BottomNavGlobal(selectedIndex: 0),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// _BottomItem eliminado (se usa BottomNavGlobal)

  double _parsePeso(Map<String, dynamic> registro) {
    final p = registro['peso'];
    if (p is num) return p.toDouble();
    if (p is String) return double.tryParse(p) ?? 0.0;
    if (registro['pesoNumerico'] is num) return (registro['pesoNumerico'] as num).toDouble();
    return 0.0;
  }