import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/peso_provider.dart';

class RegistroPesoDetallePantalla extends StatefulWidget {
  final Map<String,dynamic> registro;
  final String mascotaId;
  const RegistroPesoDetallePantalla({super.key, required this.registro, required this.mascotaId});

  @override
  State<RegistroPesoDetallePantalla> createState() => _RegistroPesoDetallePantallaState();
}

class _RegistroPesoDetallePantallaState extends State<RegistroPesoDetallePantalla> {
  late TextEditingController _pesoCtrl;
  late TextEditingController _obsCtrl;
  bool _editando = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _pesoCtrl = TextEditingController(text: (widget.registro['peso']?.toString() ?? ''));
    _obsCtrl = TextEditingController(text: (widget.registro['observaciones'] ?? '').toString());
  }

  @override
  void dispose() {
    _pesoCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fechaStr = _formatFecha(widget.registro['fecha'] ?? widget.registro['createdAt']);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Peso'),
        actions: [
          if (!_editando)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editando = true),
            ),
          if (_editando)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _editando = false),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _eliminar,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: $fechaStr', style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 16),
            TextField(
              controller: _pesoCtrl,
              enabled: _editando,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _obsCtrl,
              enabled: _editando,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Observaciones'),
            ),
            const SizedBox(height: 24),
            if (_editando)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando ? const SizedBox(height:16,width:16,child: CircularProgressIndicator(strokeWidth:2,color: Colors.white)) : const Icon(Icons.save),
                  label: const Text('Guardar cambios'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    final prov = context.read<PesoProvider>();
    setState(() { _guardando = true; });
    final id = (widget.registro['_id'] ?? widget.registro['id']).toString();
    final ok = await prov.actualizar(id, {
      'peso': double.tryParse(_pesoCtrl.text.trim()),
      'observaciones': _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
    });
    setState(() { _guardando = false; });
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro actualizado')));
      setState(() { _editando = false; });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(prov.error ?? 'Error al actualizar'), backgroundColor: Colors.red));
    }
  }

  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: const Text('¿Seguro que deseas eliminar este registro de peso?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar != true) return;
    final prov = context.read<PesoProvider>();
    final id = (widget.registro['_id'] ?? widget.registro['id']).toString();
    final ok = await prov.eliminar(id);
    if (ok && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro eliminado')));
    } else if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(prov.error ?? 'Error al eliminar'), backgroundColor: Colors.red));
    }
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
}
