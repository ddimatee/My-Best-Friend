import 'package:flutter/material.dart';
import 'detalle_peso.dart';
import 'peso.dart';

class HistorialPesoPantalla extends StatefulWidget {
  final List<Map<String, dynamic>> registrosPeso;
  
  const HistorialPesoPantalla({
    Key? key, 
    required this.registrosPeso,
  }) : super(key: key);

  @override
  State<HistorialPesoPantalla> createState() => _HistorialPesoPantallaState();
}

class _HistorialPesoPantallaState extends State<HistorialPesoPantalla> {
  String _filtroSeleccionado = 'Hoy';
  late List<Map<String, dynamic>> _registrosFiltrados;

  @override
  void initState() {
    super.initState();
    _registrosFiltrados = widget.registrosPeso;
    _aplicarFiltro();
  }

  void _aplicarFiltro() {
    final ahora = DateTime.now();
    setState(() {
      switch (_filtroSeleccionado) {
        case 'Hoy':
          _registrosFiltrados = widget.registrosPeso.where((registro) {
            final fecha = registro['fecha'] as DateTime;
            return fecha.day == ahora.day && 
                   fecha.month == ahora.month && 
                   fecha.year == ahora.year;
          }).toList();
          break;
        case '1 sem.':
          final haceSemana = ahora.subtract(const Duration(days: 7));
          _registrosFiltrados = widget.registrosPeso.where((registro) {
            final fecha = registro['fecha'] as DateTime;
            return fecha.isAfter(haceSemana);
          }).toList();
          break;
        case '1 mes':
          final haceMes = DateTime(ahora.year, ahora.month - 1, ahora.day);
          _registrosFiltrados = widget.registrosPeso.where((registro) {
            final fecha = registro['fecha'] as DateTime;
            return fecha.isAfter(haceMes);
          }).toList();
          break;
        case '1 año':
          final haceAno = DateTime(ahora.year - 1, ahora.month, ahora.day);
          _registrosFiltrados = widget.registrosPeso.where((registro) {
            final fecha = registro['fecha'] as DateTime;
            return fecha.isAfter(haceAno);
          }).toList();
          break;
        case 'Personalizado':
          _registrosFiltrados = widget.registrosPeso;
          break;
      }
    });
  }

  String _formatearFechaCompleta(DateTime fecha) {
    const meses = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${fecha.day} ${meses[fecha.month]} ${fecha.year} - ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  void _eliminarRegistro(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar registro'),
          content: const Text('¿Estás seguro de que deseas eliminar este registro de peso?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.registrosPeso.removeAt(index);
                  _aplicarFiltro();
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
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PesoPantalla(
                      registrosExistentes: widget.registrosPeso,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros de tiempo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Primera fila de filtros
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFiltroButton('Hoy'),
                    _buildFiltroButton('1 sem.'),
                    _buildFiltroButton('1 mes'),
                    _buildFiltroButton('1 año'),
                  ],
                ),
                const SizedBox(height: 8),
                // Segunda fila - Personalizado
                _buildFiltroButton('Personalizado'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Lista de registros
          Expanded(
            child: _registrosFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets,
                          size: 80,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay registros para el período seleccionado',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
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
                      final pesoKg = (double.tryParse(registro['peso']) ?? 0) / 1000;
                      
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetallePesoPantalla(
                                registro: registro,
                                onActualizar: (registroActualizado) {
                                  setState(() {
                                    final indexOriginal = widget.registrosPeso.indexOf(registro);
                                    if (indexOriginal != -1) {
                                      widget.registrosPeso[indexOriginal] = registroActualizado;
                                      _aplicarFiltro();
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Ícono de mascota
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.pets,
                                color: Colors.orange.shade600,
                                size: 24,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Información del peso
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${pesoKg.toStringAsFixed(3)} kg',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatearFechaCompleta(registro['fecha']),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (registro['notas'].isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      registro['notas'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            // Botones de acción
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    // TODO: Implementar edición
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Función de editar próximamente'),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () => _eliminarRegistro(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _mostrarFiltroPersonalizado() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _FiltroPersonalizadoDialog(
          onFiltrar: (fechaDesde, fechaHasta) {
            setState(() {
              _filtroSeleccionado = 'Personalizado';
              if (fechaDesde != null && fechaHasta != null) {
                _registrosFiltrados = widget.registrosPeso.where((registro) {
                  final fecha = registro['fecha'] as DateTime;
                  return fecha.isAfter(fechaDesde.subtract(const Duration(days: 1))) &&
                         fecha.isBefore(fechaHasta.add(const Duration(days: 1)));
                }).toList();
              } else {
                _registrosFiltrados = widget.registrosPeso;
              }
            });
          },
          onRestablecer: () {
            setState(() {
              _filtroSeleccionado = 'Hoy';
              _aplicarFiltro();
            });
          },
        );
      },
    );
  }

  Widget _buildFiltroButton(String texto) {
    final isSelected = _filtroSeleccionado == texto;
    return GestureDetector(
      onTap: () {
        if (texto == 'Personalizado') {
          _mostrarFiltroPersonalizado();
        } else {
          setState(() {
            _filtroSeleccionado = texto;
          });
          _aplicarFiltro();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _FiltroPersonalizadoDialog extends StatefulWidget {
  final Function(DateTime?, DateTime?) onFiltrar;
  final VoidCallback onRestablecer;

  const _FiltroPersonalizadoDialog({
    Key? key,
    required this.onFiltrar,
    required this.onRestablecer,
  }) : super(key: key);

  @override
  State<_FiltroPersonalizadoDialog> createState() => _FiltroPersonalizadoDialogState();
}

class _FiltroPersonalizadoDialogState extends State<_FiltroPersonalizadoDialog> {
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  Future<void> _seleccionarFecha(bool esDesde) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

    if (fecha != null) {
      setState(() {
        if (esDesde) {
          _fechaDesde = fecha;
        } else {
          _fechaHasta = fecha;
        }
      });
    }
  }

  String _formatearFechaSelector(DateTime? fecha) {
    if (fecha == null) return 'Seleccionar fecha';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtrar Pesos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Campo Desde
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Desde',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _seleccionarFecha(true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatearFechaSelector(_fechaDesde),
                            style: TextStyle(
                              fontSize: 16,
                              color: _fechaDesde == null ? Colors.grey.shade600 : Colors.black87,
                            ),
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
              ],
            ),

            const SizedBox(height: 16),

            // Campo Hasta
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hasta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _seleccionarFecha(false),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatearFechaSelector(_fechaHasta),
                            style: TextStyle(
                              fontSize: 16,
                              color: _fechaHasta == null ? Colors.grey.shade600 : Colors.black87,
                            ),
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
              ],
            ),

            const SizedBox(height: 32),

            // Botones
            Column(
              children: [
                // Botón Filtrar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onFiltrar(_fechaDesde, _fechaHasta);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Filtrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Botón Restablecer
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onRestablecer();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Restablecer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}