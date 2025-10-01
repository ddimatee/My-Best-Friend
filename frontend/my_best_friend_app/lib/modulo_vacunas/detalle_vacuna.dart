import 'package:flutter/material.dart';
import '../modulo_general/widgets/bottom_nav_global.dart';
import 'package:intl/intl.dart';
import '../../providers/vacunas_provider.dart';
import 'package:provider/provider.dart';
import 'formulario_vacuna.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint

class DetalleVacuna extends StatefulWidget {
  final Map<String, dynamic> vacuna;

  const DetalleVacuna({Key? key, required this.vacuna}) : super(key: key);

  @override
  State<DetalleVacuna> createState() => _DetalleVacunaState();
}

class _DetalleVacunaState extends State<DetalleVacuna> {
  final Color _greenColor = const Color(0xFF4CAF50);
  late Map<String, dynamic> _vacunaActual;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _vacunaActual = Map<String, dynamic>.from(widget.vacuna);
  }

  Future<void> _recargarVacuna() async {
    setState(() => _cargando = true);
    try {
      final prov = context.read<VacunasProvider>();
      final id = _vacunaActual['_id'] ?? _vacunaActual['id'];
      
      // Recargar todas las vacunas para obtener la actualizada
      await prov.cargarVacunas(forzar: true);
      
      // Buscar la vacuna actualizada
      final todasVacunas = prov.todasLasVacunas();
      final vacunaActualizada = todasVacunas.firstWhere(
        (v) => (v['_id'] ?? v['id']) == id,
        orElse: () => _vacunaActual,
      );
      
      setState(() {
        _vacunaActual = Map<String, dynamic>.from(vacunaActualizada);
        _cargando = false;
      });
      
      debugPrint('✅ Vacuna recargada: $_vacunaActual');
    } catch (e) {
      debugPrint('❌ Error al recargar: $e');
      setState(() => _cargando = false);
    }
  }

  Future<void> _editarVacuna() async {
    debugPrint('🔧 Editando vacuna: ${_vacunaActual['_id'] ?? _vacunaActual['id']}');
    // Pasar los datos de la vacuna actual para editar
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioVacuna(vacuna: _vacunaActual),
      ),
    );
    if (resultado == true) {
      debugPrint('✅ Vacuna editada, recargando datos...');
      await _recargarVacuna();
    }
  }

  Future<void> _eliminarVacuna() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar vacuna'),
          content: const Text('¿Estás seguro de que deseas eliminar esta vacuna?'),
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
        debugPrint('🗑️ Intentando eliminar vacuna...');
        final prov = context.read<VacunasProvider>();
        final id = _vacunaActual['_id'] ?? _vacunaActual['id'];
        
        if (id == null) {
          debugPrint('❌ Error: ID de vacuna es null');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: ID de vacuna no válido'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        debugPrint('🔍 ID de vacuna: $id');
        final ok = await prov.eliminarVacuna(id.toString());
        
        if (!mounted) return;
        
        if (ok) {
          debugPrint('✅ Vacuna eliminada exitosamente');
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Vacuna eliminada'),
              backgroundColor: _greenColor,
            ),
          );
        } else {
          debugPrint('❌ Error al eliminar: ${prov.error}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(prov.error ?? 'Error al eliminar la vacuna'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint('❌ Excepción al eliminar: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _obtenerTextoRecordatorio() {
    if (_vacunaActual['recordatorio']?['fechaRecordatorio'] != null) {
      try {
        // Parsear la fecha UTC del backend y convertirla a hora local
        final fechaUTC = DateTime.parse(_vacunaActual['recordatorio']['fechaRecordatorio'].toString());
        final fechaLocal = fechaUTC.toLocal(); // Convertir de UTC a hora local
        
        final fecha = DateFormat('d MMM yyyy', 'es').format(fechaLocal);
        final hora = DateFormat('h:mm a').format(fechaLocal);
        
        return 'Activado\n$fecha • $hora';
      } catch (e) {
        return 'Activado';
      }
    }
    return 'Activado';
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
          'Detalle de Vacuna',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del perro
            Center(
              child: Container(
                width: 140,
                height: 140,
                margin: const EdgeInsets.only(bottom: 24),
                child: Image.asset(
                  'assets/images/vacuna.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(70),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        size: 70,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Nombre de la vacuna (destacado)
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
                  (_vacunaActual['nombre'] ?? 'Vacuna') as String,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Detalles de la vacuna
            _buildDetailRow(
              'Fecha de aplicación',
              DateFormat('dd/MM/yyyy').format(DateTime.tryParse(_vacunaActual['fechaAplicacion']?.toString() ?? '') ?? DateTime.now()),
              icon: Icons.calendar_today,
            ),
            
            _buildDetailRow(
              'Lugar de aplicación',
              (_vacunaActual['ubicacion']?.toString().trim().isEmpty ?? true) 
                  ? '—' 
                  : _vacunaActual['ubicacion'].toString(),
              icon: Icons.location_on,
            ),
            
      if ((_vacunaActual['observaciones'] ?? _vacunaActual['descripcion'] ?? '')
        .toString()
        .isNotEmpty)
              _buildDetailRow(
                'Descripción',
        (_vacunaActual['observaciones'] ?? _vacunaActual['descripcion'] ?? '')
          .toString(),
                icon: Icons.description,
              ),
            
            _buildDetailRow(
              'Recordatorio',
              (_vacunaActual['recordatorio']?['activo'] == true) 
                ? _obtenerTextoRecordatorio()
                : 'Desactivado',
              icon: (_vacunaActual['recordatorio']?['activo'] == true)
                  ? Icons.notifications_active 
                  : Icons.notifications_off,
            ),
            
            const SizedBox(height: 32),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _editarVacuna,
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
                    onPressed: _eliminarVacuna,
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
      
      bottomNavigationBar: const BottomNavGlobal(selectedIndex: 0),
    );
  }
}
// _BottomItem eliminado (se usa BottomNavGlobal)