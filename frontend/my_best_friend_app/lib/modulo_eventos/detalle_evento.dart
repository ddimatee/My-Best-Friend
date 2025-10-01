import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/eventos_provider.dart';
import 'formulario_evento.dart';

class DetalleEvento extends StatefulWidget {
  final Map<String,dynamic> evento;

  const DetalleEvento({Key? key, required this.evento}) : super(key: key);

  @override
  State<DetalleEvento> createState() => _DetalleEventoState();
}

class _DetalleEventoState extends State<DetalleEvento> {
  final Color _greenColor = const Color(0xFF4CAF50);

  Future<void> _editarEvento() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioEvento(
          tipoInicial: (widget.evento['tipo'] ?? widget.evento['categoria'] ?? 'evento').toString(),
          evento: widget.evento,
          mascotaId: (widget.evento['mascota'] is Map)
              ? (widget.evento['mascota']['_id'] ?? widget.evento['mascota']['id']).toString()
              : (widget.evento['mascota']?.toString()),
        ),
      ),
    );

    if (resultado == true) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _eliminarEvento() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar evento'),
          content: const Text('¿Estás seguro de que deseas eliminar este evento?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      try {
  final id = widget.evento['_id'] ?? widget.evento['id'];
  final prov = context.read<EventosProvider>();
  final success = await prov.eliminar(id);
        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Evento eliminado exitosamente'),
              backgroundColor: _greenColor,
            ),
          );
        } else {
          throw Exception('Error al eliminar');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar el evento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: _greenColor, size: 24),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        title: const Text(
          'Detalle del Evento',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del perro con hueso
            Center(
              child: Container(
                width: 140,
                height: 140,
                margin: const EdgeInsets.only(bottom: 24),
                child: Image.asset(
                  'assets/images/perroevento2.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error cargando imagen en detalle: $error');
                    // Fallback a otra imagen
                    return Image.asset(
                      'assets/images/perroevento2.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error2, stackTrace2) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(70),
                          ),
                          child: const Icon(
                            Icons.pets,
                            size: 70,
                            color: Colors.white,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            
            // Título del evento (destacado)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  (widget.evento['titulo'] ?? '').toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Detalles del evento
            _buildDetailRow(
              'Categoría',
              (widget.evento['tipo'] ?? widget.evento['categoria'] ?? '').toString(),
              icon: _getIconoCategoria((widget.evento['tipo'] ?? widget.evento['categoria'] ?? '').toString()),
            ),
            
            _buildDetailRow(
              'Fecha del evento',
              DateFormat('d \'de\' MMMM \'de\' yyyy').format(DateTime.tryParse(widget.evento['fecha']?.toString() ?? '') ?? DateTime.now()),
              icon: Icons.calendar_today,
            ),
            
            _buildDetailRow(
              'Hora',
              DateFormat('h:mm a').format(DateTime.tryParse(widget.evento['fecha']?.toString() ?? '') ?? DateTime.now()),
              icon: Icons.access_time,
            ),
            
            if ((widget.evento['descripcion'] ?? '').toString().isNotEmpty)
              _buildDetailRow(
                'Descripción',
                widget.evento['descripcion'].toString(),
                icon: Icons.description,
              ),
            
            _buildDetailRow(
              'Recordatorio',
        (widget.evento['recordatorio']?['activo'] == true) ? 'Activado' : 'Desactivado',
        icon: (widget.evento['recordatorio']?['activo'] == true)
          ? Icons.notifications_active
          : Icons.notifications_off,
            ),
            
            const SizedBox(height: 32),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _editarEvento,
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _greenColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _eliminarEvento,
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
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