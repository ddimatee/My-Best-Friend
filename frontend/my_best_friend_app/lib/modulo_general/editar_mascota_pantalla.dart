import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mascotas_provider.dart';
import '../widgets/custom_date_picker.dart';

class EditarMascotaPantalla extends StatefulWidget {
  final String mascotaId;
  const EditarMascotaPantalla({super.key, required this.mascotaId});

  @override
  State<EditarMascotaPantalla> createState() => _EditarMascotaPantallaState();
}

class _EditarMascotaPantallaState extends State<EditarMascotaPantalla> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  String? _sexo; // 'macho' | 'hembra'
  DateTime? _fechaNac;
  bool _cuidaConAlguien = false;
  String _estiloVida = 'mixto'; // activo | tranquilo | mixto
  bool _cargando = true;
  bool _guardando = false;

  final List<String> _opcionesSexo = ['macho', 'hembra'];
  final List<String> _opcionesEstiloVida = ['activo','tranquilo','mixto'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  void _cargar() {
    final prov = context.read<MascotasProvider>();
    final m = prov.buscarPorId(widget.mascotaId);
    if (m == null) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _nombreController.text = (m['nombre'] ?? '').toString();
      _razaController.text = (m['raza'] ?? '').toString();
      _descripcionController.text = (m['descripcion'] ?? '').toString();
      _sexo = (m['sexo'] ?? '').toString().toLowerCase().isNotEmpty ? (m['sexo'] ?? '').toString().toLowerCase() : null;
      final fechaStr = m['fechaNacimiento'] ?? m['fecha_nac'];
      if (fechaStr is String && fechaStr.isNotEmpty) {
        _fechaNac = DateTime.tryParse(fechaStr);
      } else if (fechaStr is DateTime) {
        _fechaNac = fechaStr;
      }
      _cuidaConAlguien = m['cuidaConAlguien'] == true;
      final ev = (m['estiloVida'] ?? 'mixto').toString();
      if (_opcionesEstiloVida.contains(ev)) _estiloVida = ev; else _estiloVida = 'mixto';
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    setState(() => _guardando = true);
    final prov = context.read<MascotasProvider>();
    final data = <String,dynamic>{
      'nombre': _nombreController.text.trim().isEmpty ? null : _nombreController.text.trim(),
      'raza': _razaController.text.trim().isEmpty ? null : _razaController.text.trim(),
      'descripcion': _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
      'sexo': _sexo,
      'fechaNacimiento': _fechaNac?.toIso8601String(),
      'cuidaConAlguien': _cuidaConAlguien,
      'estiloVida': _estiloVida,
    }..removeWhere((k,v) => v == null);
    final ok = await prov.actualizarMascota(widget.mascotaId, data);
    if (!mounted) return;
    setState(() => _guardando = false);
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mascota actualizada')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(prov.error ?? 'Error al actualizar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar mascota'),
        actions: [
          TextButton(
            onPressed: _guardando ? null : _guardar,
            child: _guardando
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Guardar', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titulo('Nombre'),
            _caja(TextField(
              controller: _nombreController,
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Nombre'),
            )),
            const SizedBox(height: 20),
            _titulo('Sexo'),
            Row(
              children: _opcionesSexo.map((s) {
                final sel = _sexo == s;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () => setState(() => _sexo = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: sel ? const Color(0xFF4CAF50) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: sel ? const Color(0xFF4CAF50) : Colors.grey.shade400),
                        ),
                        child: Text(
                          s == 'macho' ? 'Macho' : 'Hembra',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _titulo('Fecha de nacimiento'),
            GestureDetector(
              onTap: () async {
                final ahora = DateTime.now();
                final picked = await CustomDatePicker.show(
                  context,
                  initialDate: _fechaNac ?? ahora,
                  firstDate: DateTime(1990),
                  lastDate: ahora,
                );
                if (picked != null) setState(() => _fechaNac = picked);
              },
              child: _caja(Row(children:[
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(_fechaNac == null ? 'Seleccionar fecha' : '${_fechaNac!.day}/${_fechaNac!.month}/${_fechaNac!.year}',
                  style: TextStyle(color: _fechaNac==null?Colors.grey:Colors.black87)),
              ])),
            ),
            const SizedBox(height: 20),
            _titulo('Raza'),
            _caja(TextField(
              controller: _razaController,
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Raza'),
            )),
            const SizedBox(height: 20),
            _titulo('Descripción'),
            _caja(TextField(
              controller: _descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Descripción (opcional)'),
            )),
            const SizedBox(height: 20),
            _titulo('¿Cuidas con alguien más?'),
            Row(children:[
              _opcionBool('Sí', _cuidaConAlguien, true),
              const SizedBox(width: 8),
              _opcionBool('No', !_cuidaConAlguien, false),
            ]),
            const SizedBox(height: 20),
            _titulo('Estilo de vida'),
            Row(children: _opcionesEstiloVida.map((e){
              final sel = _estiloVida==e;
              return Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:4.0),
                child: GestureDetector(
                  onTap: ()=> setState(()=> _estiloVida=e),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical:12),
                    decoration: BoxDecoration(
                      color: sel? const Color(0xFF4CAF50): Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel? const Color(0xFF4CAF50): Colors.grey.shade400),
                    ),
                    child: Text(e, textAlign: TextAlign.center, style: TextStyle(color: sel? Colors.white: Colors.black87, fontWeight: FontWeight.w600)),
                  ),
                ),
              ));
            }).toList()),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _titulo(String t) => Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
  Widget _caja(Widget child) => Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: child,
  );
  Widget _opcionBool(String label, bool sel, bool value) => Expanded(
    child: GestureDetector(
      onTap: () => setState(()=> _cuidaConAlguien = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? const Color(0xFF4CAF50) : Colors.grey.shade400),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: sel? Colors.white: Colors.black87, fontWeight: FontWeight.w600)),
      ),
    ),
  );

  @override
  void dispose() {
    _nombreController.dispose();
    _razaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}