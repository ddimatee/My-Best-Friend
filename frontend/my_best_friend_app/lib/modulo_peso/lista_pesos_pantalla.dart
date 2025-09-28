import 'package:flutter/material.dart';
import 'detalle_peso.dart';
import 'peso.dart';

class ListaPesosPantalla extends StatefulWidget {
  final List<Map<String, dynamic>> registrosPeso;

  const ListaPesosPantalla({
    Key? key,
    required this.registrosPeso,
  }) : super(key: key);

  @override
  State<ListaPesosPantalla> createState() => _ListaPesosPantallaState();
}

class _ListaPesosPantallaState extends State<ListaPesosPantalla> {
  int _tabIndex = 0; // Índice para la barra de navegación inferior
  late List<Map<String, dynamic>> _registrosPeso;
  late List<Map<String, dynamic>> _registrosFiltrados;
  String _filtroSeleccionado = 'Hoy';

  @override
  void initState() {
    super.initState();
    _registrosPeso = List.from(widget.registrosPeso);
    _aplicarFiltro();
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
    
    setState(() {
      switch (_filtroSeleccionado) {
        case 'Hoy':
          _registrosFiltrados = _registrosPeso.where((registro) {
            final fechaRegistro = registro['fecha'] as DateTime;
            final diaRegistro = DateTime(fechaRegistro.year, fechaRegistro.month, fechaRegistro.day);
            return diaRegistro.isAtSameMomentAs(hoy);
          }).toList();
          break;
        case '1 sem.':
          final unaSemanaAtras = hoy.subtract(const Duration(days: 7));
          _registrosFiltrados = _registrosPeso.where((registro) {
            final fechaRegistro = registro['fecha'] as DateTime;
            return fechaRegistro.isAfter(unaSemanaAtras) && fechaRegistro.isBefore(ahora.add(const Duration(days: 1)));
          }).toList();
          break;
        case '1 mes':
          final unMesAtras = DateTime(ahora.year, ahora.month - 1, ahora.day);
          _registrosFiltrados = _registrosPeso.where((registro) {
            final fechaRegistro = registro['fecha'] as DateTime;
            return fechaRegistro.isAfter(unMesAtras) && fechaRegistro.isBefore(ahora.add(const Duration(days: 1)));
          }).toList();
          break;
        case '1 año':
          final unAnoAtras = DateTime(ahora.year - 1, ahora.month, ahora.day);
          _registrosFiltrados = _registrosPeso.where((registro) {
            final fechaRegistro = registro['fecha'] as DateTime;
            return fechaRegistro.isAfter(unAnoAtras) && fechaRegistro.isBefore(ahora.add(const Duration(days: 1)));
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
          final fechaRegistro = registro['fecha'] as DateTime;
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
                setState(() {
                  _registrosPeso.remove(registroAEliminar);
                });
                _aplicarFiltro();
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
        builder: (context) => PesoPantalla(registrosExistentes: _registrosPeso),
      ),
    ).then((result) {
      if (result != null && result is List<Map<String, dynamic>>) {
        setState(() {
          _registrosPeso = result;
        });
      }
    });
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _registrosFiltrados.length,
                      itemBuilder: (context, index) {
                        final registro = _registrosFiltrados[index];
                        final fecha = registro['fecha'] as DateTime;
                        
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
                                      '${_formatearPesoParaLista(registro['pesoNumerico'] as double)} kg',
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
                                    if (registro['notas'] != null && registro['notas'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        registro['notas'].toString(),
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
                                        onActualizar: (registroActualizado) {
                                          final indiceOriginal = _registrosPeso.indexOf(registro);
                                          if (indiceOriginal != -1) {
                                            setState(() {
                                              _registrosPeso[indiceOriginal] = registroActualizado;
                                            });
                                            _aplicarFiltro();
                                          }
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
      
      // Barra de navegación inferior
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

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

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