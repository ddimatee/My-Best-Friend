import 'package:flutter/material.dart';
import 'estado.dart';
import 'paso_3_sexo.dart';
import 'widgets_comunes.dart';

class MascotaPasoNombrePantalla extends StatefulWidget {
  final PetFormState estado;
  const MascotaPasoNombrePantalla({super.key, required this.estado});
  @override
  State<MascotaPasoNombrePantalla> createState() => _MascotaPasoNombrePantallaState();
}

class _MascotaPasoNombrePantallaState extends State<MascotaPasoNombrePantalla> {
  final TextEditingController _ctrl = TextEditingController();
  bool get _valido => _ctrl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Text('¿Cómo se llama tu\nperro?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
            ),
            child: TextField(
              controller: _ctrl,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Escribe el nombre',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 16),
          BotonSiguiente(
            habilitado: _valido,
            etiqueta: 'Siguiente',
            onTap: () {
              widget.estado.name = _ctrl.text.trim();
              Navigator.push(context, MaterialPageRoute(builder: (_) => MascotaPasoSexoPantalla(estado: widget.estado)));
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                widget.estado.name = 'Sin nombre';
                Navigator.push(context, MaterialPageRoute(builder: (_) => MascotaPasoSexoPantalla(estado: widget.estado)));
              },
              child: const Text('No lo he elegido todavía', style: TextStyle(color: Colors.black87)),
            ),
          ),
        ]),
      ),
    );
  }
}
